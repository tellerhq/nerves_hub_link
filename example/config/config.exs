# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Customize non-Elixir parts of the firmware. See
# https://hexdocs.pm/nerves/advanced-configuration.html for details.
config :nerves, :firmware, rootfs_overlay: "rootfs_overlay"

# Use shoehorn to start the main application. See the shoehorn
# docs for separating out critical OTP applications such as those
# involved with firmware updates.
config :shoehorn,
  init: [:nerves_runtime, :nerves_init_gadget],
  app: Mix.Project.config()[:app]

config :nerves_init_gadget,
  ifname: "wlan0",
  address_method: :dhcp,
  mdns_domain: "nerves.local",
  node_name: "app",
  node_host: :mdns_domain

config :nerves_firmware_ssh,
  authorized_keys: [
    File.read!(Path.join(System.user_home!, ".ssh/id_rsa.pub"))
  ]

network_ssid = System.get_env("NERVES_NETWORK_SSID") ||
  Mix.shell.info "NERVES_NETWORK_SSID is unset"
network_psk = System.get_env("NERVES_NETWORK_PSK") ||
  Mix.shell.info "NERVES_NETWORK_PSK is unset"

key_mgmt = System.get_env("NERVES_NETWORK_KEY_MGMT") || "WPA-PSK"

config :nerves_network, :default,
  wlan0: [ssid: network_ssid, psk: network_psk, key_mgmt: key_mgmt]

config :nerves_hub, NervesHub.Socket,
  url: "wss://192.168.1.103:4443/socket/websocket",
  serializer: Jason,
  ssl_verify: :verify_peer,
  socket_opts: [
    certfile: "/root/device-1234.pem" |> to_charlist,
    keyfile: "/root/device-1234-key.pem" |> to_charlist,
    cacertfile: "/root/ca.pem" |> to_charlist,
    server_name_indication: 'device.nerves-hub.org'
  ]

# Import target specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
# Uncomment to use target specific configurations

# import_config "#{Mix.Project.config[:target]}.exs"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"