import SwiftUI
import SwiftData

// Reto opcional: la consulta, el contenedor y el manejo de errores ya están listos.
struct PersistentTodoScreen: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \StoredTodo.createdAt) private var todos: [StoredTodo]
    @State private var newTodoText = ""
    @State private var errorMessage: String?

    private var remainingCount: Int {
        todos.filter { !$0.isDone }.count
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    LabHeader(remainingCount: remainingCount, totalCount: todos.count,
                              storageLabel: "SwiftData · guardado en este simulador")
                }
                Section("Nueva tarea") {
                    HStack {
                        TextField("¿Qué quieres hacer?", text: $newTodoText)
                            .accessibilityIdentifier("newTodoField")
                            .submitLabel(.done)
                            .onSubmit { addTodo() }
                        Button(action: addTodo) {
                            Image(systemName: "plus.circle.fill").font(.title2)
                        }
                        .accessibilityLabel("Agregar tarea")
                        .accessibilityIdentifier("addTodoButton")
                        .disabled(newTodoText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        .buttonStyle(.borderless)
                    }
                }
                Section("Mis tareas") {
                    if todos.isEmpty {
                        ContentUnavailableView("Comienza tu lista persistente",
                                               systemImage: "externaldrive",
                                               description: Text("Las tareas de la práctica en memoria no se copian aquí."))
                    }
                    ForEach(todos) { todo in
                        TodoRow(title: todo.title, isDone: todo.isDone,
                                onToggle: {
                                    todo.isDone.toggle()
                                    saveChanges()
                                },
                                onDelete: { deleteTodo(todo) })
                    }
                }
            }
            .navigationTitle("Mis tareas")
            .alert("No se pudo guardar", isPresented: Binding(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )) {
                Button("Entendido", role: .cancel) { errorMessage = nil }
            } message: {
                Text(errorMessage ?? "Intenta nuevamente.")
            }
        }
    }

    private func addTodo() {
        let title = newTodoText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else { return }
        // EXTRA 2: inserta un StoredTodo en modelContext (una línea).
        modelContext.insert(StoredTodo(title: title))
        if saveChanges() { newTodoText = "" }
    }

    private func deleteTodo(_ todo: StoredTodo) {
        // EXTRA 3: elimina todo de modelContext (una línea).
        modelContext.delete(todo)
        saveChanges()
    }

    @discardableResult
    private func saveChanges() -> Bool {
        do {
            try modelContext.save()
            return true
        } catch {
            modelContext.rollback()
            errorMessage = "No se guardaron los cambios. Intenta de nuevo. \(error.localizedDescription)"
            return false
        }
    }
}

#Preview {
    PersistentTodoScreen()
        .modelContainer(for: StoredTodo.self, inMemory: true)
}
