import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["input", "previewContainer"]

    connect() {
        this.dt = new DataTransfer()
        this.previewContainerTarget.innerHTML = ''
    }

    preview() {
        this.previewContainerTarget.innerHTML = ''
        const files = this.inputTarget.files

        // 1. Add new files to DataTransfer accumulator
        for (let i = 0; i < files.length; i++) {
            // Prevent duplicates based on name and size (basic check)
            const file = files[i]
            let duplicate = false
            for (let j = 0; j < this.dt.files.length; j++) {
                if (this.dt.files[j].name === file.name && this.dt.files[j].size === file.size) {
                    duplicate = true
                    break
                }
            }
            if (!duplicate) this.dt.items.add(file)
        }

        // 2. Update input.files with the accumulated list
        this.inputTarget.files = this.dt.files

        // 3. Render Previews from the accumulated list
        this.renderPreviews()
    }

    renderPreviews() {
        this.previewContainerTarget.innerHTML = ''
        if (this.dt.files.length > 0) {
            const title = document.createElement('h4')
            title.className = "text-sm font-medium text-gray-700 mb-2"
            title.innerText = "New Images Preview"
            this.previewContainerTarget.appendChild(title)

            const grid = document.createElement('div')
            grid.className = "flex flex-wrap gap-4"
            this.previewContainerTarget.appendChild(grid)

            Array.from(this.dt.files).forEach((file, index) => {
                const reader = new FileReader()

                reader.onload = (e) => {
                    const div = document.createElement('div')
                    div.className = "relative group w-24"

                    const img = document.createElement('img')
                    img.src = e.target.result
                    img.className = "h-24 w-24 object-cover rounded-md border"

                    const name = document.createElement('p')
                    name.className = "text-xs text-gray-500 mt-1 truncate w-24"
                    name.innerText = file.name

                    // Remove Button
                    const removeBtn = document.createElement('button')
                    removeBtn.type = 'button'
                    removeBtn.className = "absolute -top-2 -right-2 bg-gray-500 text-white rounded-full p-1 shadow-md hover:bg-gray-700 transition"
                    removeBtn.innerHTML = `
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-3 w-3" viewBox="0 0 20 20" fill="currentColor">
                            <path fill-rule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clip-rule="evenodd" />
                        </svg>
                    `
                    removeBtn.onclick = (e) => {
                        e.stopPropagation()
                        this.removeFile(index)
                    }

                    div.appendChild(img)
                    div.appendChild(name)
                    div.appendChild(removeBtn)
                    grid.appendChild(div)
                }

                reader.readAsDataURL(file)
            })
        }
    }

    removeFile(index) {
        const dtNew = new DataTransfer()
        for (let i = 0; i < this.dt.files.length; i++) {
            if (i !== index) dtNew.items.add(this.dt.files[i])
        }
        this.dt = dtNew
        this.inputTarget.files = this.dt.files
        this.renderPreviews()
    }

    triggerInput(e) {
        e.preventDefault()
        this.inputTarget.click()
    }
}
