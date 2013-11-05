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
            
# Resulting XML configuration file for controller

Names etc should probably change? Perhaps <server> isn't the best tag for instance.

  <?xml version="1.0" encoding="utf-8"?>
  <server>
	<interface>
		<port>6726</port>
		<address>0.0.0.0</address>
	</interface>
	<groups>
		<radio-groups>
			<radio-group>
				<name>all</name>
				<description>all radios</description>
				<filters>
					<!-- here goes filters -->
				</filters>
				<policy>
					<signal-dbm>42</signal-dbm>
					<priority>1</priority>
				</policy>
			</radio-group>
		</radio-groups>
		<service-groups>
			<service-group>
				<name>all</name>
				<description>all services</description>
				<filters>
					<!-- here goes filters -->
				</filters>
				<policy>
					<signal-dbm>42</signal-dbm>
					<priority>2</priority>
				</policy>
			</service-group>
		</service-groups>
		<client-groups>
			<client-group>
				<name>all</name>
				<description>all clients</description>
				<filters>
					<!-- here goes filters -->
				</filters>
				<policy>
					<signal-dbm>42</signal-dbm>
					<priority>1</priority>
				</policy>
			</client-group>
			<client-group>
				<name>special-client</name>
				<description>a special client group</description>
				<filters>
					<!-- here goes filters -->
				</filters>
				<policy>
					<signal-dbm>42</signal-dbm>
					<priority>100</priority>
				</policy>
			</client-group>
		</client-groups>
	</groups>
	<apps>
		<app>
			<type>simple</type>
			
			<radios>
				<radio>all</radio>
			</radios>
			<services>
				<service>all</service>
			</services>
			<clients>
				<client>all</client>
			</clients>			
			<config>
				<!-- here goes the specific config for this app -->
			</config>
		</app>
	</apps>
  </server>


