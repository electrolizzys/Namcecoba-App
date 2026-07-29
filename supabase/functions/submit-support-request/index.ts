import { createClient } from "https://esm.sh/@supabase/supabase-js@2.49.1";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const anonKey = Deno.env.get("SUPABASE_ANON_KEY")!;

    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return json({ error: "Missing Authorization" }, 401);
    }

    const userClient = createClient(supabaseUrl, anonKey, {
      global: { headers: { Authorization: authHeader } },
    });
    const {
      data: { user },
      error: userError,
    } = await userClient.auth.getUser();
    if (userError || !user) {
      return json({ error: "Unauthorized" }, 401);
    }

    const body = await req.json();
    const message = String(body?.message ?? "").trim();
    if (message.length < 3) {
      return json({ error: "Message is required" }, 400);
    }
    if (message.length > 2000) {
      return json({ error: "Message is too long" }, 400);
    }

    const adminClient = createClient(supabaseUrl, serviceRoleKey);

    const { data: profile } = await adminClient
      .from("profiles")
      .select("username, email, role")
      .eq("id", user.id)
      .maybeSingle();

    const senderName =
      profile?.username ||
      user.user_metadata?.username ||
      user.email ||
      "User";
    const senderRole = profile?.role ?? "customer";
    const senderEmail = profile?.email || user.email || "";

    const { data: admins, error: adminsError } = await adminClient
      .from("profiles")
      .select("id")
      .eq("role", "admin");

    if (adminsError) {
      return json({ error: adminsError.message }, 500);
    }
    if (!admins?.length) {
      return json({ error: "No admin accounts found" }, 404);
    }

    const title = `Support from ${senderName}`;
    const notificationBody =
      `[${senderRole}] ${senderEmail}\n\n${message}`.slice(0, 1800);

    const rows = admins.map((admin: { id: string }) => ({
      user_id: admin.id,
      title,
      body: notificationBody,
      type: "support",
      reference_id: user.id,
      is_read: false,
    }));

    const { error: insertError } = await adminClient
      .from("notifications")
      .insert(rows);

    if (insertError) {
      return json({ error: insertError.message }, 500);
    }

    return json({ ok: true, notified: rows.length });
  } catch (error) {
    return json(
      { error: error instanceof Error ? error.message : "Unknown error" },
      500,
    );
  }
});

function json(payload: unknown, status = 200) {
  return new Response(JSON.stringify(payload), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}
