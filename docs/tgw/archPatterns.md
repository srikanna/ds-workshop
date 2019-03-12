
## Review following architecture patterns.

1. On-Prem-->VPN-->TGW-->VPCs (Multi account setup.)

2. **Edge routing** : Limit traffic between VPCs while still communicate over the VPN

3. **Shared services/Security appliance** : Leverage the existing VPN tunnel.

4. **Dual homed VPCs** . A scenario where an end customer owns the TGW in their accounts and shares it with an MSP for managing a suite of applications. In this scenario MSP however would like to retain the control of communication between VPCs, and from their premises to VPCs. For that a TGW will be used in the MSP account as well, and this makes the VPCs dual homed.
