import SwiftUI

struct TodoScreen: View {
    // @State conserva el estado mientras esta vista mantiene su identidad.
    // Los cambios de estado hacen que SwiftUI actualice la interfaz.
    @State private var todos = Todo.examples
    @State private var newTodoText = ""

    private var remainingCount: Int {
        // LAB 4: reemplaza este valor por el número de tareas no completadas.
        todos.filter { !$0.isDone }.count
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    LabHeader(remainingCount: remainingCount, totalCount: todos.count,
                              storageLabel: "En memoria · laboratorio principal")
                }
                Section("Nueva tarea") {
                    HStack {
                        TextField("¿Qué quieres hacer?", text: $newTodoText)
                            .accessibilityIdentifier("newTodoField")
                            .submitLabel(.done)
                            .onSubmit { addTodo() }
                        Button(action: addTodo) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                        }
                        .accessibilityLabel("Agregar tarea")
                        .accessibilityIdentifier("addTodoButton")
                        .disabled(newTodoText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        .buttonStyle(.borderless)
                    }
                }
                Section("Mis tareas") {
                    if todos.isEmpty {
                        ContentUnavailableView("Tu lista está lista",
                                               systemImage: "checkmark.circle",
                                               description: Text("Agrega una tarea para comenzar."))
                    }
                    ForEach(todos) { todo in
                        TodoRow(title: todo.title, isDone: todo.isDone,
                                onToggle: { toggleTodo(id: todo.id) },
                                onDelete: { todos.removeAll { $0.id == todo.id } })
                    }
                }
            }
            .navigationTitle("Mis tareas")
        }
    }

    private func addTodo() {
        let title = newTodoText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else { return }
        // LAB 2: agrega una tarea y limpia el campo (dos líneas).
        todos.append(Todo(title: title))
        newTodoText = ""
    }

    private func toggleTodo(id: UUID) {
        guard let index = todos.firstIndex(where: { $0.id == id }) else { return }
        // LAB 3: invierte isDone en la tarea ubicada en index (una línea).
        todos[index].isDone.toggle()
    }
}

#Preview {
    TodoScreen()
        .tint(LabSettings.accentColor)
}
