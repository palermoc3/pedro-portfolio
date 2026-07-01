import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "panel"]

  connect() {
    this.open = false
    this.element.dataset.mobileMenuReady = "true"
  }

  toggle() {
    this.open ? this.close() : this.show()
  }

  show() {
    if (this.open) return

    this.open = true
    this.element.classList.add("is-open")
    this.buttonTarget.setAttribute("aria-expanded", "true")
    this.buttonTarget.setAttribute("aria-label", "Fechar menu de navegação")
    this.panelTarget.setAttribute("aria-hidden", "false")
    document.body.classList.add("overflow-hidden")
  }

  close() {
    if (!this.open) return

    this.open = false
    this.element.classList.remove("is-open")
    this.buttonTarget.setAttribute("aria-expanded", "false")
    this.buttonTarget.setAttribute("aria-label", "Abrir menu de navegação")
    this.panelTarget.setAttribute("aria-hidden", "true")
    document.body.classList.remove("overflow-hidden")
  }
}
