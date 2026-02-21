// 離脱予兆検知: 3日以上未学習のユーザーを講師へ通知
// pg_cron で日次実行を推奨

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

Deno.serve(async (req) => {
  try {
    const client = createClient(supabaseUrl, supabaseServiceKey);

    const today = new Date().toISOString().split("T")[0];
    const threeDaysAgo = new Date();
    threeDaysAgo.setDate(threeDaysAgo.getDate() - 3);
    const cutoff = threeDaysAgo.toISOString().split("T")[0];

    const { data: stats } = await client
      .from("user_stats")
      .select("user_id, last_study_date, streak_count")
      .not("last_study_date", "is", null);

    if (!stats || stats.length === 0) {
      return new Response(JSON.stringify({ detected: 0 }), {
        headers: { "Content-Type": "application/json" },
        status: 200,
      });
    }

    const { data: assignments } = await client
      .from("consultant_assignments")
      .select("consultant_id, client_id")
      .eq("status", "active");

    const assignmentMap = new Map<string, string>();
    for (const a of assignments || []) {
      assignmentMap.set(a.client_id, a.consultant_id);
    }

    let inserted = 0;
    for (const s of stats) {
      const lastStudy = (s.last_study_date as string) || "";
      if (lastStudy < cutoff) {
        const consultantId = assignmentMap.get(s.user_id);
        if (!consultantId) continue;

        const daysInactive = Math.floor(
          (new Date(today).getTime() - new Date(lastStudy).getTime()) /
            (1000 * 60 * 60 * 24)
        );

        const { data: existing } = await client
          .from("dropout_alerts")
          .select("id")
          .eq("client_id", s.user_id)
          .is("acknowledged_at", null)
          .limit(1);

        if (existing && existing.length > 0) continue;

        const { error } = await client.from("dropout_alerts").insert({
          client_id: s.user_id,
          consultant_id: consultantId,
          alert_type: "no_study",
          days_inactive: daysInactive,
          last_activity_date: lastStudy,
        });

        if (!error) inserted++;
      }
    }

    return new Response(
      JSON.stringify({ detected: stats.length, inserted }),
      { headers: { "Content-Type": "application/json" }, status: 200 }
    );
  } catch (e) {
    return new Response(JSON.stringify({ error: String(e) }), {
      headers: { "Content-Type": "application/json" },
      status: 500,
    });
  }
});
