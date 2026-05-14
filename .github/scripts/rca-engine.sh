#!/usr/bin/env bash

# ==========================================
# RCA / Root Cause Analysis Engine
# ==========================================
#
# Purpose:
#
# Generates:
# - probable root cause
# - suggested operator checks
# - estimated recovery window
# - severity classification
#
# Inputs:
# - site name
# - latency
#
# Outputs:
# - RCA
# - CHECKS
# - ETA
# - SEVERITY
#
# ==========================================

generate_rca() {

  local SITE="$1"

  local LATENCY="$2"

  RCA=""
  CHECKS=""
  ETA=""
  SEVERITY="⚠️ Minor"

  LOWER=$(echo "$SITE" \
    | tr '[:upper:]' '[:lower:]')

  # ========================================
  # TEST / STAGING ENVIRONMENTS
  # ========================================

  if [[ "$LOWER" =~ test|debug|sandbox|staging|dev ]]; then

    RCA="Deployment instability or staging environment regression."

    CHECKS="• Review deployment logs
• Validate API endpoints
• Inspect feature flags"

    ETA="Likely short-lived"

    SEVERITY="🧪 Testing"

    return

  fi
  # ========================================
  # LARGE PUBLIC SERVICES / CDN
  # ========================================

  if [[ "$LOWER" =~ google|wikipedia|github|cloudflare|amazon|flipkart|youtube|instagram ]]; then

    RCA="External provider or CDN edge instability."

    CHECKS="• Verify provider outage status
• Retry from alternate network
• Validate local DNS resolution"

    ETA="Usually transient"

    SEVERITY="🌐 External"

    return

  fi

  # ========================================
  # UNKNOWN LATENCY
  # Usually:
  # - DNS
  # - SSL
  # - hard outage
  # - upstream timeout
  # ========================================

  if [ "$LATENCY" = "unknown" ]; then

    RCA="DNS resolution failure or upstream connectivity disruption."

    CHECKS="• Validate DNS + SSL
• Inspect provider/CDN status
• Verify origin reachability"

    ETA="Dependent on provider recovery"

    SEVERITY="🛑 Critical"

    return

  fi

  # ========================================
  # Invalid latency fallback
  # ========================================

  if ! [[ "$LATENCY" =~ ^[0-9]+$ ]]; then

    RCA="Telemetry corruption or invalid latency metrics detected."

    CHECKS="• Verify monitoring agents
• Inspect telemetry ingestion
• Validate Upptime history files
• Check observability persistence"

    ETA="Monitoring telemetry recovery"

    SEVERITY="⚠️ Minor"

    return
  fi

  # ========================================
  # CRITICAL LATENCY
  # ========================================

  if [ "$LATENCY" -gt 5000 ]; then

    RCA="Severe infrastructure overload or upstream service collapse."

    CHECKS="• Check server CPU/RAM utilization
• Inspect database saturation
• Validate reverse proxy health
• Review hosting provider metrics
• Check DDoS / traffic spikes
• Verify deployment stability
• Inspect upstream APIs"

    ETA="15–45 mins"

    SEVERITY="🛑 Critical"

  # ========================================
  # MAJOR LATENCY
  # ========================================

  elif [ "$LATENCY" -gt 3000 ]; then

    RCA="Backend saturation or infrastructure overload detected."

    CHECKS="• Inspect CPU/RAM + DB load
• Verify upstream/API health
• Review deployment changes"

    ETA="15–45 mins"

    SEVERITY="🚨 Major"

  # ========================================
  # HIGH LATENCY
  # ========================================

  elif [ "$LATENCY" -gt 1500 ]; then

    RCA="Severe upstream latency and degraded application responsiveness."

    CHECKS="• Inspect backend response times
• Verify network/provider health
• Review traffic anomalies"

    ETA="10–30 mins"


    SEVERITY="🚨 Major"

  # ========================================
  # MODERATE LATENCY
  # ========================================

  elif [ "$LATENCY" -gt 700 ]; then

    RCA="Elevated latency detected prior to service degradation."

    CHECKS="• Verify upstream dependencies
• Inspect hosting stability
• Monitor latency drift"

    ETA="Monitoring recovery"

    SEVERITY="⚠️ Moderate"

  # ========================================
  # LOW LATENCY FAILURE
  # Usually:
  # - transient networking
  # - SSL handshake
  # - brief routing issue
  # ========================================

  else

    RCA="Short-lived network instability or transient routing degradation."

    CHECKS="• Validate upstream reachability
• Inspect routing/provider health
• Verify TLS/SSL integrity"

    ETA="Likely transient"

    SEVERITY="⚠️ Minor"
    
  fi

  # ========================================
  # Flapping signal enrichment
  # ========================================

  if [ -f "observability/incident-metrics.json" ]; then

    FLAP_COUNT=$(jq -r \
      --arg slug "$(echo "$LOWER" | sed 's/ /-/g')" \
      '.[$slug].incidents // 0' \
      observability/incident-metrics.json)

    if [ "$FLAP_COUNT" -gt 5 ]; then

      RCA="$RCA

Repeated instability patterns detected over historical monitoring."

      CHECKS="$CHECKS
• Inspect recurring failure patterns
• Validate autoscaling behavior
• Review historical incident trends"

      ETA="Potential recurring infrastructure instability"

    fi
  fi
}
