import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "input", "previews" ]

  preview() {
    this.previewsTarget.innerHTML = ""
    for (const file of this.inputTarget.files) {
      const img = document.createElement("img")
      img.src = URL.createObjectURL(file)
      img.onload = () => URL.revokeObjectURL(img.src)
      this.previewsTarget.appendChild(img)
    }
  }
}
