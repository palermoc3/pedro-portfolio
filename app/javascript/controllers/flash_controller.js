import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // Fecha o alerta automaticamente após 2 segundos
    setTimeout(() => {
      this.dismiss()
    }, 2000)
  }

  dismiss() {
    this.element.style.transition = "opacity 0.5s ease"
    this.element.style.opacity = "0"
    setTimeout(() => {
      this.element.remove()
    }, 500)
  }
}