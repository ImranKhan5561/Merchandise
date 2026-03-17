import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["typeCheckbox", "valuesContainer"]

    toggleType(event) {
        const checkbox = event.target
        const typeId = checkbox.value

        // Find the corresponding values container
        const container = this.valuesContainerTargets.find(
            el => el.dataset.typeId === typeId
        )

        if (container) {
            container.classList.toggle("hidden", !checkbox.checked)

            // If unchecking, also uncheck all nested values
            if (!checkbox.checked) {
                container.querySelectorAll('input[type="checkbox"]').forEach(cb => {
                    cb.checked = false
                })
            }
        }
    }
}
