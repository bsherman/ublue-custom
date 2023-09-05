set allow-duplicate-recipes

distrobox-fedora:
  echo 'Creating Fedora distrobox ...'
  distrobox create --nvidia --image ghcr.io/bsherman/fedora-toolbox-custom:FEDORA_MAJOR_VERSION -n fedora -Y

setup-flatpaks:
  echo 'Setting up your flatpaks...'
  flatpak install -y --system \\
  com.seafile.Client \\
  com.simplenote.Simplenote \\
  nl.hjdskes.gcolor3 \\
  org.gimp.GIMP \\
  com.ktechpit.whatsie \\
  org.signal.Signal \\
  us.zoom.Zoom
  
setup-flatpak-overrides-pwa:
  echo 'Giving browser permission to create PWAs (Progressive Web Apps)'
  # Add for your favorite chromium-based browser
  flatpak override --system --filesystem=~/.local/share/applications --filesystem=~/.local/share/icons com.brave.Browser
  flatpak override --system --filesystem=~/.local/share/applications --filesystem=~/.local/share/icons com.microsoft.Edge

setup-gaming-educational:
  echo 'Setting up educational gaming experience ...'
  flatpak install -y --system \\
  org.kde.kturtle \\
  edu.mit.Scratch \\
  com.tux4kids.tuxmath \\
  com.tux4kids.tuxtype \\
  org.tuxpaint.Tuxpaint

setup-gaming-light:
  echo 'Setting up light gaming experience ...'
  flatpak install -y --system \\
  net.sourceforge.lgames.LTris \\
  org.frozen_bubble.frozen-bubble \\
  org.gnome.Aisleriot \\
  org.gnome.Crosswords \\
  org.gnome.Mines

setup-gaming-linux:
  echo 'Setting up linux gaming experience ...'
  flatpak install -y --system \\
  io.github.retux_game.retux \\
  net.sourceforge.ExtremeTuxRacer \\
  net.supertuxkart.SuperTuxKart \\
  org.supertuxproject.SuperTux \\
  org.armagetronad.ArmagetronAdvanced \\
  party.supertux.supertuxparty

setup-gaming-minecraft:
  echo 'Setting up minecraft gaming experience ...'
  flatpak install -y --system \\
  com.mojang.Minecraft \\
  io.mrarm.mcpelauncher \\
  org.prismlauncher.PrismLauncher

setup-gaming-serious:
  echo 'Setting up serious gaming experience ... lock and load.'
  flatpak install -y --system \\
  org.freedesktop.Platform.VulkanLayer.MangoHud//22.08 \\
  org.freedesktop.Platform.VulkanLayer.vkBasalt//22.08 \\
  com.github.Matoking.protontricks \\
  com.heroicgameslauncher.hgl \\
  com.usebottles.bottles \\
  com.valvesoftware.Steam \\
  com.valvesoftware.Steam.Utility.gamescope \\
  com.valvesoftware.Steam.CompatibilityTool.Boxtron \\
  com.valvesoftware.Steam.CompatibilityTool.Proton \\
  com.valvesoftware.Steam.CompatibilityTool.Proton-Exp \\
  com.valvesoftware.Steam.CompatibilityTool.Proton-GE

setup-flatpak-overrides-gaming:
  flatpak override com.usebottles.bottles --system --filesystem=xdg-data/applications
  flatpak override --system --env=MANGOHUD=1 com.valvesoftware.Steam
  flatpak override --system --env=MANGOHUD=1 com.heroicgameslauncher.hgl

setup-media-flatpaks:
  echo 'Setting up creative media flatpaks...'
  flatpak install -y --system \\
  org.audacityteam.Audacity \\
  org.inkscape.Inkscape \\
  org.kde.kdenlive \\
  org.kde.krita \\
  org.freedesktop.Platform.VulkanLayer.OBSVkCapture//22.08 \\
  com.obsproject.Studio \\
  com.obsproject.Studio.Plugin.OBSVkCapture \\
  com.obsproject.Studio.Plugin.Gstreamer

setup-other-flatpaks:
  echo 'Setting up misc other flatpaks...'
  flatpak install -y --system \\
  com.belmoussaoui.Obfuscate \\
  com.discordapp.Discord \\
  com.google.Chrome \\
  com.microsoft.Edge \\
  com.skype.Client \\
  com.slack.Slack \\
  com.visualstudio.code \\
  de.haeckerfelix.Fragments \\
  org.flameshot.Flameshot \\
  org.gnome.Firmware \\
  org.gnome.seahorse.Application \\
  org.telegram.desktop \\
  re.sonny.Junction \\
  tech.feliciano.pocket-casts
