#!/usr/bin/env bash

generate_rca() {

  local SITE="$1"
  local LATENCY="$2"

  RCA=""
  CHECKS=""
  ETA=""
  SEVERITY="⚠️ Minor"

  LOWER=$(echo "$SITE" | tr '[:upper:]' '[:lower:]')

  # ========================================
  # TEST / STAGING
  # ========================================

  if [[ "$LOWER" =~ test|debug|sandbox|staging|dev ]]; then

    RCA="Possible deployment/testing instability."

    CHECKS="• Verify CI/CD pipelines
• Check API endpoints
• Review deployment logs
• Inspect recent commits
• Validate feature toggles"

    ETA="Likely short-lived"

    SEVERITY="🧪 Testing"

    return
  fi

  # ========================================
  # PUBLIC / CDN SITES
  # ========================================

  if [[ "$LOWER" =~ google|wikipedia|github ]]; then

    RCA="Likely CDN or provider-side instability."

    CHECKS="• Retry from another network
• Verify local DNS
• Check public outage trackers
• Validate ISP connectivity"

    ETA="Usually transient"

    SEVERITY="🌐 External"

    return
  fi

  # ========================================
  # UNKNOWN LATENCY
  # ========================================

  if [ "$LATENCY" = "unknown" ]; then

    RCA="DNS resolution or upstream connectivity issue."

    CHECKS="• Verify DNS records
• Check SSL certificates
• Inspect Cloudflare dashboard
• Validate hosting provider health
• Test server reachability"

    ETA="Dependent on provider recovery"

    SEVERITY="🛑 Critical"

    return
  fi

  # ========================================
  # MASSIVE LATENCY
  # ========================================

  if [ "$LATENCY" -gt 3000 ]; then

    RCA="Progressive backend degradation or infrastructure overload."

    CHECKS="• Check CPU/RAM usage
• Inspect reverse proxy health
• Verify database performance
• Review Cloudflare analytics
• Monitor hosting metrics
• Inspect deployment changes"

    ETA="10–30 mins"

    SEVERITY="🛑 Critical"

  # ========================================
  # HIGH LATENCY
  # ========================================

  elif [ "$LATENCY" -gt 1500 ]; then

    RCA="High upstream latency and degraded application responsiveness."

    CHECKS="• Review application logs
• Verify API response times
• Monitor network bottlenecks
• Inspect resource utilization"

    ETA="5–15 mins"

    SEVERITY="🚨 Major"

  # ========================================
  # MEDIUM LATENCY
  # ========================================

  elif [ "$LATENCY" -gt 700 ]; then

    RCA="Elevated latency detected before outage."

    CHECKS="• Verify upstream APIs
• Inspect hosting stability
• Monitor DNS health"

    ETA="Monitoring recovery"

    SEVERITY="⚠️ Moderate"

  # ========================================
  # LOW LATENCY FAILURE
  # ========================================

  else

    RCA="Temporary connectivity instability."

    CHECKS="• Verify SSL validity
• Inspect routing/network path
• Review transient connectivity"

    ETA="Likely transient"

    SEVERITY="⚠️ Minor"

  fi
}
