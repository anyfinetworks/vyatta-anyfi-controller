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
                    ip-filter <txt: IP FILTER>
                    mac-filter <txt: MAC FILTER>

                service-group <txt: SERVICE GROUP NAME>
                    description <txt: DESCRIPTION>
                    ip-filter <txt: IP FILTER>
                    uuid-filter <txt: UUID FILTER>

                client-group <txt: CLIENT GROUP NAME>
                    description <txt: DESCRIPTION>
                    mac-filter <txt: MAC FILTER>

                app
                    simple <txt: INSTANCE NAME>
                        description <txt: DESCRIPTION>
                        radios <txt: RADIO GROUP NAME or ANY>
                        services <txt: SERVICE GROUP NAME or ANY>
                        clients <txt: CLIENT GROUP NAME or ANY>
                        radio-policy
                            min-signal-level <s8: MIN SIGNAL LEVEL IN DBM>
                            min-uplink-capacity <float: MIN UPLINK CAPACITY IN MBPS>
                            min-downlink-capacity <float: MIN UPLINK CAPACITY IN MBPS>
                            min-dwell-time <u8: MIN DWELL TIME IN SECONDS>
                            kick-out
                            when
                                client
                                    has-preference-for
                                        nearby-service
                                            [radio-policy]
                                service
                                    is-nearby
                                        [radio-policy]

                    hotspot <txt: INSTANCE NAME>
                        description <txt: DESCRIPTION>
                        radios <txt: RADIO GROUP NAME or ANY>
                        services <txt: SERVICE GROUP NAME or ANY>
                        clients <txt: CLIENT GROUP NAME or ANY>
                        breadcast-ssid
                        radio-policy
                            min-signal-level <s8: MIN SIGNAL LEVEL IN DBM>
                            min-uplink-capacity <float: MIN UPLINK CAPACITY IN MBPS>
                            min-downlink-capacity <float: MIN UPLINK CAPACITY IN MBPS>
                            min-dwell-time <u8: MIN DWELL TIME IN SECONDS>
                            kick-out
                            when
                                client
                                    has-preference-for
                                        nearby-service
                                            [radio-policy]

# Operational Commands

    show
        anyfi
            controller
                radios
                services
                relays

    restart
        anyfi
            controller   # Restarts the Controller
