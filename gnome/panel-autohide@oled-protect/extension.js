import St from "gi://St";

import { Extension } from "resource:///org/gnome/shell/extensions/extension.js";
import * as Main from "resource:///org/gnome/shell/ui/main.js";

export default class PanelAutoHide extends Extension {
  enable() {
    this._panelBox = Main.layoutManager.panelBox;
    this._panelBoxStyle = this._panelBox.get_style() ?? null;
    this._themeContext = St.ThemeContext.get_for_stage(global.stage);

    this._scaleFactorId = this._themeContext.connect(
      "notify::scale-factor",
      () => {
        if (!Main.panel.visible) this._applyPanelBoxMinHeight();
      },
    );

    this._showingId = Main.overview.connect("showing", () => this._showPanel());
    this._hidingId = Main.overview.connect("hiding", () => this._hidePanel());

    if (Main.overview.visible) this._showPanel();
    else this._hidePanel();
  }

  disable() {
    if (this._showingId) {
      Main.overview.disconnect(this._showingId);
      this._showingId = 0;
    }

    if (this._hidingId) {
      Main.overview.disconnect(this._hidingId);
      this._hidingId = 0;
    }

    if (this._scaleFactorId) {
      this._themeContext.disconnect(this._scaleFactorId);
      this._scaleFactorId = 0;
    }

    this._showPanel();
    this._panelBox = null;
    this._themeContext = null;
  }

  _showPanel() {
    Main.panel.show();
    this._panelBox.set_style(this._panelBoxStyle);
    this._setPanelStruts(true);
  }

  _hidePanel() {
    this._panelHeight =
      Main.panel.height || Main.panel.get_preferred_height(-1)[1];
    Main.panel.hide();
    this._applyPanelBoxMinHeight();

    this._setPanelStruts(false);
  }

  _applyPanelBoxMinHeight() {
    const height = this._panelHeight || Main.panel.get_preferred_height(-1)[1];
    const minHeight = height / this._themeContext.scale_factor;
    const baseStyle = this._panelBoxStyle ? `${this._panelBoxStyle} ` : "";
    this._panelBox.set_style(`${baseStyle}min-height: ${minHeight}px;`);
  }

  _setPanelStruts(affectsStruts) {
    Main.layoutManager.removeChrome(this._panelBox);
    Main.layoutManager.addChrome(this._panelBox, {
      affectsStruts,
      trackFullscreen: true,
    });
  }
}
