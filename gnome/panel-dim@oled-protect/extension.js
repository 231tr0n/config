import GLib from "gi://GLib";
import St from "gi://St";

import { Extension } from "resource:///org/gnome/shell/extensions/extension.js";
import * as Main from "resource:///org/gnome/shell/ui/main.js";

const MIN_BRIGHTNESS = 0x77;
const MAX_BRIGHTNESS = 0xff;
const INTERVAL_SECONDS = 1;
const STEP_DELTA = (MAX_BRIGHTNESS - MIN_BRIGHTNESS) / 720;

export default class OledPanelProtect extends Extension {
  enable() {
    this._brightness = MIN_BRIGHTNESS;
    this._direction = 1;
    this._timeoutId = 0;
    this._labelState = new Map();

    this._applyColor();
    this._timeoutId = GLib.timeout_add(
      GLib.PRIORITY_DEFAULT,
      INTERVAL_SECONDS * 1000,
      () => {
        this._step();
        return GLib.SOURCE_CONTINUE;
      },
    );
  }

  disable() {
    if (this._timeoutId) {
      GLib.source_remove(this._timeoutId);
      this._timeoutId = 0;
    }

    this._restoreLabels();
    this._labelState = null;
  }

  _step() {
    this._brightness += this._direction * STEP_DELTA;
    if (this._brightness >= MAX_BRIGHTNESS) {
      this._brightness = MAX_BRIGHTNESS;
      this._direction = -1;
    } else if (this._brightness <= MIN_BRIGHTNESS) {
      this._brightness = MIN_BRIGHTNESS;
      this._direction = 1;
    }

    this._applyColor();
  }

  _applyColor() {
    const level = Math.round(this._brightness);
    const hex = `#${level.toString(16).padStart(2, "0").repeat(3)}`;
    const style = `color: ${hex};`;

    for (const label of this._collectLabels(Main.panel)) {
      if (!this._labelState.has(label)) {
        const destroyId = label.connect("destroy", () => {
          this._labelState?.delete(label);
        });
        this._labelState.set(label, {
          style: label.get_style() ?? "",
          destroyId,
        });
      }

      if (label.get_style() !== style) label.set_style(style);
    }
  }

  _collectLabels(actor) {
    const labels = [];

    if (actor instanceof St.Label) labels.push(actor);

    for (const child of actor.get_children())
      labels.push(...this._collectLabels(child));

    return labels;
  }

  _restoreLabels() {
    for (const [label, { style, destroyId }] of this._labelState) {
      label.disconnect(destroyId);
      label.set_style(style);
    }

    this._labelState.clear();
  }
}
