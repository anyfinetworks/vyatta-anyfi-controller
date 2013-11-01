Vyatta CLI for ANYFI CONTROLLER
===============================

# Goals and Objectives

Provide a Vyatta (and EdgeOS) CLI for ANYFI CONTROLLER, allowing centralized
orchestration of other software products from Anyfi Networks, as well as all
third party networking equipment incorporating [Anyfi.net software](http://anyfi.net/software).

# Functional Specification

The user will be able to configure the Controller to instantiate SDWN apps which
will connect SDWN radios and services on-demand. Each instantiated application 
will enable a separate carrier Wi-Fi service for end-subscribers.

For a more complete description see the
[ANYFI CONTROLLER datasheet](http://www.anyfinetworks.com/files/anyfi-controller-datasheet.pdf).

# Configuration Commands

    service
        anyfi
            controller
                radio-group <txt: RADIO GROUP NAME>
                    description <txt: DESCRIPTION>
                    ip <txt: IP SELECTOR>
                    mac <txt: MAC SELECTOR>
                    policy
                        min-signal-level <number>
                        min-upstream-bandwidth <txt: BANDWIDTH SPEC>
                        min-downstream-bandwidth <txt: BANDWIDTH SPEC>
                        min-dwell-time <txt: TIME SPEC>
                        kick-out
                        priority <number>

                service-group <txt: SERVICE GROUP NAME>
                    description <txt: DESCRIPTION>
                    ip <txt: IP SELECTOR>
                    ssid <txt: SSID>
                    uuid <txt: UUID>
                    policy
                        ...

                client-group <txt: CLIENT GROUP NAME>
                    description <txt: DESCRIPTION>
                    mac <txt: MAC SELECTOR>
                    policy
                        ...

                simple-app <txt: INSTANCE NAME>
                    description <txt: DESCRIPTION>
                    radios <txt: RADIO GROUP NAME>
                    services <txt: SERVICE GROUP NAME>
                    clients <txt: CLIENT GROUP NAME>
                    ...

                mobile-app <txt: INSTANCE NAME>
                    description <txt: DESCRIPTION>
                    radios <txt: RADIO GROUP NAME>
                    services <txt: SERVICE GROUP NAME>
                    clients <txt: CLIENT GROUP NAME>
                    ...

                hotspot-app <txt: INSTANCE NAME>
                    description <txt: DESCRIPTION>
                    radios <txt: RADIO GROUP NAME>
                    services <txt: SERVICE GROUP NAME>
                    clients <txt: CLIENT GROUP NAME>
                    ...

                inbound-roaming
                    ...

                outbound-roaming
                    ...

# Operational Commands

    show
        anyfi
            controller   # Shows runtime information

    restart
        anyfi
            controller   # Restarts the Controller

