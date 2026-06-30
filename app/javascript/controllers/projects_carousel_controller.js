import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["track", "item", "dot"]

  connect() {
    this.update()
  }

  previous() {
    this.trackTarget.scrollBy({ left: -this.step, behavior: "smooth" })
  }

  next() {
    this.trackTarget.scrollBy({ left: this.step, behavior: "smooth" })
  }

  goTo(event) {
    const index = event.params.index
    this.itemTargets[index]?.scrollIntoView({
      behavior: "smooth",
      block: "nearest",
      inline: "start"
    })
  }

  update() {
    if (!this.hasItemTarget) return

    const currentIndex = this.itemTargets.reduce((closestIndex, item, index) => {
      const currentDistance = Math.abs(item.offsetLeft - this.trackTarget.scrollLeft)
      const closestDistance = Math.abs(this.itemTargets[closestIndex].offsetLeft - this.trackTarget.scrollLeft)

      return currentDistance < closestDistance ? index : closestIndex
    }, 0)

    this.dotTargets.forEach((dot, index) => {
      const isCurrent = index === currentIndex

      dot.setAttribute("aria-current", isCurrent)
      dot.classList.toggle("w-6", isCurrent)
      dot.classList.toggle("bg-[#6366F1]", isCurrent)
      dot.classList.toggle("bg-[#94A3B8]/45", !isCurrent)
    })
  }

  get step() {
    return this.trackTarget.clientWidth
  }
}
