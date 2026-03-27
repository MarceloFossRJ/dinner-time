import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "tags", "submit", "count"]

  connect() {
    this.updateState()
  }

  add() {
    const value = this.inputTarget.value.trim()
    if (!value) return

    if (this.isDuplicate(value)) {
      this.inputTarget.setCustomValidity("Ingredient already added")
      this.inputTarget.reportValidity()
      return
    }

    this.inputTarget.setCustomValidity("")
    this.appendTag(value)
    this.inputTarget.value = ""
    this.updateState()
  }

  remove(event) {
    const pill = event.target.closest(".ingredient-pill")
    if (pill) pill.remove()
    this.updateState()
  }

  appendTag(value) {
    const pill = document.createElement("span")
    pill.className = "badge bg-primary d-flex align-items-center gap-1 fs-6 fw-normal py-2 px-3 ingredient-pill"
    pill.innerHTML = `
      ${this.escapeHtml(value)}
      <button type="button" class="btn-close btn-close-white" aria-label="Remove"
              style="font-size:0.6rem"
              data-action="click->ingredients#remove"></button>
      <input type="hidden" name="ingredients[]" value="${this.escapeHtml(value)}">
    `
    this.tagsTarget.appendChild(pill)
  }

  isDuplicate(value) {
    const existing = this.tagsTarget.querySelectorAll("input[name='ingredients[]']")
    return Array.from(existing).some(
      input => input.value.toLowerCase() === value.toLowerCase()
    )
  }

  updateState() {
    const tagCount = this.tagsTarget.querySelectorAll("input[name='ingredients[]']").length
    if (this.hasCountTarget) {
      this.countTarget.textContent = `${tagCount}/3`
    }
    if (this.hasSubmitTarget) {
      this.submitTarget.disabled = tagCount < 3
    }
  }

  escapeHtml(str) {
    return str
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;")
      .replace(/'/g, "&#039;")
  }
}
