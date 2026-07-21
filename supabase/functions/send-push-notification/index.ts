import { createClient } from "https://esm.sh/@supabase/supabase-js@2.49.1";
import * as jose from "https://deno.land/x/jose@v5.2.4/index.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type, x-webhook-secret",
};

interface NotificationRecord {
  id: string;
  user_id: string;
  title: string;
  body: string;
  type: string;
  reference_id: string | null;
}

interface WebhookPayload {
  type: string;
  table: string;
  record: NotificationRecord;
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const webhookSecret = Deno.env.get("PUSH_WEBHOOK_SECRET");
    if (webhookSecret) {
      const provided = req.headers.get("x-webhook-secret");
      if (provided !== webhookSecret) {
        return new Response(JSON.stringify({ error: "Unauthorized" }), {
          status: 401,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
      }
    }

    const payload = (await req.json()) as WebhookPayload;
    const record = payload.record;

    if (!record?.user_id || !record.title || !record.body) {
      return new Response(JSON.stringify({ error: "Invalid payload" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    );

    const { data: tokens, error: tokenError } = await supabase
      .from("device_tokens")
      .select("token")
      .eq("user_id", record.user_id);

    if (tokenError) throw tokenError;
    if (!tokens?.length) {
      return new Response(
        JSON.stringify({ sent: 0, message: "No device tokens for user" }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    const apnsJwt = await createApnsJwt();
    const useSandbox = Deno.env.get("APNS_USE_SANDBOX") !== "false";
    const host = useSandbox
      ? "https://api.sandbox.push.apple.com"
      : "https://api.push.apple.com";
    const bundleId = Deno.env.get("APNS_BUNDLE_ID") ?? "freeuni.Namtsetsoba";

    const apnsPayload = {
      aps: {
        alert: { title: record.title, body: record.body },
        sound: "default",
      },
      type: record.type,
      reference_id: record.reference_id,
    };

    let sent = 0;
    const failures: string[] = [];

    for (const row of tokens) {
      const response = await fetch(`${host}/3/device/${row.token}`, {
        method: "POST",
        headers: {
          authorization: `bearer ${apnsJwt}`,
          "apns-topic": bundleId,
          "apns-push-type": "alert",
          "apns-priority": "10",
          "content-type": "application/json",
        },
        body: JSON.stringify(apnsPayload),
      });

      if (response.ok) {
        sent += 1;
      } else {
        const body = await response.text();
        failures.push(`${row.token}: ${response.status} ${body}`);
      }
    }

    return new Response(
      JSON.stringify({ sent, failures }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    return new Response(JSON.stringify({ error: message }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});

async function createApnsJwt(): Promise<string> {
  const keyId = Deno.env.get("APNS_KEY_ID");
  const teamId = Deno.env.get("APNS_TEAM_ID");
  const privateKeyPem = Deno.env.get("APNS_PRIVATE_KEY")?.replace(/\\n/g, "\n");

  if (!keyId || !teamId || !privateKeyPem) {
    throw new Error(
      "Missing APNS_KEY_ID, APNS_TEAM_ID, or APNS_PRIVATE_KEY secrets",
    );
  }

  const key = await jose.importPKCS8(privateKeyPem, "ES256");
  return await new jose.SignJWT({})
    .setProtectedHeader({ alg: "ES256", kid: keyId })
    .setIssuer(teamId)
    .setIssuedAt()
    .sign(key);
}
