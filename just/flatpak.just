# Setup flathub remote, remove fedora remote if present
setup-flatpak-repos:
    flatpak remote-add --if-not-exists --system flathub https://flathub.org/repo/flathub.flatpakrepo
    flatpak uninstall --system --noninteractive `flatpak list --all --columns origin,application|grep ^fedora|awk '{print $2}'|xargs`
    flatpak remote-delete --system fedora --force

# Install typical GNOME apps
install-apps-gnome:
    flatpak install --noninteractive --system flathub \\
      org.gnome.Calculator \\
      org.gnome.Calendar \\
      org.gnome.Characters \\
      org.gnome.Connections \\
      org.gnome.Contacts \\
      org.gnome.Evince \\
      org.gnome.Logs \\
      org.gnome.Loupe \\
      org.gnome.Maps \\
      org.gnome.NautilusPreviewer \\
      org.gnome.TextEditor \\
      org.gnome.Weather \\
      org.gnome.baobab \\
      org.gnome.clocks \\
      org.gnome.font-viewer \\
      org.gnome.SimpleScan \\
      org.gnome.SoundRecorder \\
      org.fedoraproject.MediaWriter \\
      org.mozilla.firefox \\
      com.github.tchx84.Flatseal \\
      com.mattjakeman.ExtensionManager \\
      io.github.celluloid_player.Celluloid \\
      it.mijorus.gearlever \\
      io.missioncenter.MissionCenter \\
      org.gustavoperedo.FontDownloader

# Install typical KDE apps
install-apps-kde:
    flatpak install --noninteractive --system flathub \\
      app/org.fedoraproject.MediaWriter/x86_64/stable \\
      app/org.mozilla.Thunderbird/x86_64/stable \\
      app/org.mozilla.firefox/x86_64/stable \\
      app/org.kde.kcalc/x86_64/stable \\
      app/org.kde.gwenview/x86_64/stable \\
      app/org.kde.kontact/x86_64/stable \\
      app/org.kde.okular/x86_64/stable \\
      app/org.kde.kweather/x86_64/stable \\
      app/org.kde.kclock/x86_64/stable \\
      app/org.kde.haruna/x86_64/stable \\
      app/org.kde.filelight/x86_64/stable \\
      app/com.github.tchx84.Flatseal/x86_64/stable \\
      app/io.github.dvlv.boxbuddyrs/x86_64/stable \\
      app/io.github.flattool.Warehouse/x86_64/stable \\
      app/org.fedoraproject.MediaWriter/x86_64/stable \\
      app/io.missioncenter.MissionCenter/x86_64/stable \\
      app/it.mijorus.gearlever/x86_64/stable

# Install Productivity and Communications apps
install-apps-productivity:
    flatpak install -y --system \\
      com.google.Chrome \\
      com.microsoft.Edge \\
      com.seafile.Client \\
      com.simplenote.Simplenote \\
      io.github.mimbrero.WhatsAppDesktop \\
      org.signal.Signal \\
      us.zoom.Zoom

# Install Creative Media Apps
install-apps-creative:
    flatpak install -y --system \\
      nl.hjdskes.gcolor3 \\
      org.audacityteam.Audacity \\
      org.gimp.GIMP \\
      org.inkscape.Inkscape \\
      org.kde.kdenlive \\
      org.kde.krita

# Install Other misc apps for my home users
install-apps-misc:
    flatpak install -y --system \\
      com.belmoussaoui.Obfuscate \\
      com.discordapp.Discord \\
      com.skype.Client \\
      com.slack.Slack \\
      de.haeckerfelix.Fragments \\
      org.gnome.Firmware \\
      org.gnome.seahorse.Application \\
      org.telegram.desktop \\
      tech.feliciano.pocket-casts

# Give browsers permission to create PWAs (Progressive Web Apps)
install-pwa-flatpak-overrides:
    flatpak override --system --filesystem=~/.local/share/applications --filesystem=~/.local/share/icons com.google.Chrome
    flatpak override --system --filesystem=~/.local/share/applications --filesystem=~/.local/share/icons com.brave.Browser
    flatpak override --system --filesystem=~/.local/share/applications --filesystem=~/.local/share/icons com.microsoft.Edge

# Install educational games
install-games-educational:
    flatpak install -y --system \\
      org.kde.kturtle \\
      edu.mit.Scratch \\
      com.tux4kids.tuxmath \\
      com.tux4kids.tuxtype \\
      org.tuxpaint.Tuxpaint

# Install light/casual games
install-games-light:
    flatpak install -y --system \\
      net.sourceforge.lgames.LTris \\
      org.frozen_bubble.frozen-bubble \\
      org.gnome.Aisleriot \\
      org.gnome.Mines

# Install Linux games
install-games-linux:
    flatpak install -y --system \\
      io.github.retux_game.retux \\
      net.sourceforge.ExtremeTuxRacer \\
      net.supertuxkart.SuperTuxKart \\
      org.supertuxproject.SuperTux \\
      org.armagetronad.ArmagetronAdvanced \\
      party.supertux.supertuxparty

# Install Minecraft games
install-games-minecraft:
    flatpak install -y --system \\
      com.mojang.Minecraft \\
      io.mrarm.mcpelauncher \\
      org.prismlauncher.PrismLauncher

# Install Steam with MangoHud, Gamescope and Prototricks
install-games-steam:
    flatpak install -y --system \\
      org.freedesktop.Platform.VulkanLayer.MangoHud//22.08 \\
      com.github.Matoking.protontricks \\
      com.valvesoftware.Steam \\
      com.valvesoftware.Steam.Utility.gamescope
