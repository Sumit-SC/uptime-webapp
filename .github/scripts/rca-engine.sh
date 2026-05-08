#!/usr/bin/env bash

# ==========================================
# RCA Intelligence Engine
# ==========================================

generate_rca() {

  local SITE="$1"
  local LATENCY="$2"

  RCA=""
  CHECKS=""
  ETA=""
  SEVERITY="⚠️ Minor"

  LOWER=$(echo "$SITE" | tr '[:upper:]' '[:lower:]')

  # ========================================
  # TEST / STAGING SITES
  # ========================================

  if [[ "$LOWER" =~ test|debug|sandbox|staging|dev ]]; then

    RCA="Possible deployment/testing instability."

    CHECKS="• Verify CI/CD pipelines
• Check API endpoints
• Review deployment logs
• Inspect recent commits
• Validate feature toggles"

    ETA="Likely short-lived"

    SEVERITY="🧪 Test Alert"

    return
  fi

  # ========================================
  # PUBLIC WEBSITES
  # ========================================

  if [[ "$LOWER" =~ google|wikipedia|github ]]; then

    RCA="Likely CDN or provider-side instability."

    CHECKS="• Retry from another network
• Verify local DNS resolution
• Check public outage trackers
• Validate ISP connectivity"

    ETA="Usually transient"

    SEVERITY="🌐 External Service"

    return
  fi

  # ========================================
  # UNKNOWN LATENCY
  # ========================================

  if [ "$LATENCY" = "unknown" ]; then

    RCA="DNS resolution or upstream connectivity issue."

    CHECKS="• Verify DNS records
• Check SSL certificates
• Inspect hosting provider status
• Validate Cloudflare configuration
• Test server reachability"

    ETA="Dependent on provider recovery"

    SEVERITY="🛑 Critical"

    return
  fi

  # ========================================
  # LATENCY BASED RCA
  # ========================================

  if [ "$LATENCY" -gt 3000 ]; then

    RCA="Progressive backend degradation or infrastructure overload."

    CHECKS="• Check CPU/RAM usage
• Review reverse proxy health
• Inspect database latency
• Check Cloudflare analytics
• Verify hosting metrics
• Inspect recent deployments"

    ETA="10–30 mins"

    SEVERITY="🛑 Critical"

  elif [ "$LATENCY" -gt 1500 ]; then

    RCA="High upstream latency and degraded server responsiveness."

    CHECKS="• Verify API response times
• Review application logs
• Inspect network bottlenecks
• Monitor resource utilization"

    ETA="5–15 mins"

    SEVERITY="🚨 Major"

  elif [ "$LATENCY" -gt 700 ]; then

    RCA="Elevated response latency detected before outage."

    CHECKS="• Verify hosting stability
• Review DNS health
• Monitor upstream APIs"

    ETA="Monitoring recovery"

    SEVERITY="⚠️ Moderate"

  else

    RCA="Temporary connectivity instability."

    CHECKS="• Verify DNS health
• Check SSL validity
• Inspect routing/network path"

    ETA="Likely transient"

    SEVERITY="⚠️ Minor"

  fi
}
