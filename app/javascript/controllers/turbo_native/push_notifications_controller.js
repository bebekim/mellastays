import { Controller } from "stimulus"

export default class extends Controller {
  connect() {
    window.TurboNativeBridge.postMessage("registerForPushNotifications")
  }
}