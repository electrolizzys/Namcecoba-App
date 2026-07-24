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

    const adminClient = createClient(supabaseUrl, serviceRoleKey);

    const { data: profile, error: profileError } = await adminClient
      .from("profiles")
      .select("role")
      .eq("id", user.id)
      .single();

    if (profileError || profile?.role !== "admin") {
      return json({ error: "Admin only" }, 403);
    }

    const body = await req.json();
    const store = body.store;
    const account = body.account;

    if (!store?.name || !account?.email || !account?.password) {
      return json({ error: "store and account fields are required" }, 400);
    }

    const { data: storeRow, error: storeError } = await adminClient
      .from("stores")
      .insert({
        name: store.name,
        address: store.address,
        latitude: store.latitude,
        longitude: store.longitude,
        category: store.category,
        rating: store.rating ?? 0,
        open_time: store.open_time ?? "09:00",
        close_time: store.close_time ?? "21:00",
      })
      .select()
      .single();

    if (storeError || !storeRow) {
      return json({ error: storeError?.message ?? "Failed to create store" }, 400);
    }

    const { data: created, error: createUserError } =
      await adminClient.auth.admin.createUser({
        email: account.email,
        password: account.password,
        email_confirm: true,
        user_metadata: { username: account.username ?? store.name },
      });

    if (createUserError || !created.user) {
      await adminClient.from("stores").delete().eq("id", storeRow.id);
      return json(
        { error: createUserError?.message ?? "Failed to create venue user" },
        400,
      );
    }

    const { error: profileUpdateError } = await adminClient
      .from("profiles")
      .upsert({
        id: created.user.id,
        email: account.email,
        username: account.username ?? store.name,
        role: "venue",
        store_id: storeRow.id,
      });

    if (profileUpdateError) {
      await adminClient.auth.admin.deleteUser(created.user.id);
      await adminClient.from("stores").delete().eq("id", storeRow.id);
      return json({ error: profileUpdateError.message }, 400);
    }

    return json({ store: storeRow }, 200);
  } catch (error) {
    return json(
      { error: error instanceof Error ? error.message : "Unknown error" },
      500,
    );
  }
});

function json(payload: unknown, status: number) {
  return new Response(JSON.stringify(payload), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}
