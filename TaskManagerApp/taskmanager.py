import tkinter as tk
from tkinter import messagebox
import json
from datetime import datetime

# Initialize list to store tasks
tasks = []

# Define the color scheme (single mode)
bg_color = "#2C3E50"  # Dark blue background
btn_color = "#1ABC9C"  # Teal buttons
text_color = "#ECF0F1"  # Light text
accent_color = "#E74C3C"  # Accent for remove buttons

# Use modern fonts
font_title = ("Helvetica", 20, "bold")
font_default = ("Helvetica", 12)
font_btn = ("Helvetica", 12, "bold")

def create_gui():
    """Create the main GUI window."""
    root = tk.Tk()
    root.title("To-Do List Application")
    root.geometry("600x500")
    root.configure(bg=bg_color)

    # Add a label at the top with matching background
    label = tk.Label(root, text="To-Do List", font=font_title, fg=text_color, bg=bg_color)
    label.pack(pady=10)

    # Add a listbox to display tasks
    task_listbox = tk.Listbox(root, height=15, width=80, font=font_default, bg="#34495E", fg=text_color, selectbackground="#1ABC9C")
    task_listbox.pack(pady=10)

    # Create a frame for the buttons with matching background
    button_frame = tk.Frame(root, bg=bg_color)
    button_frame.pack(pady=10)

    # Add buttons to the frame
    add_button = tk.Button(button_frame, text="Add Task", command=lambda: add_task_gui(task_listbox), bg=btn_color, fg=text_color, font=font_btn, relief="flat", width=12)
    remove_button = tk.Button(button_frame, text="Remove Task", command=lambda: remove_task_gui(task_listbox), bg=accent_color, fg=text_color, font=font_btn, relief="flat", width=12)
    complete_button = tk.Button(button_frame, text="Mark Complete", command=lambda: mark_task_complete_gui(task_listbox), bg=btn_color, fg=text_color, font=font_btn, relief="flat", width=12)
    edit_button = tk.Button(button_frame, text="Edit Task", command=lambda: edit_task_gui(task_listbox), bg="#F39C12", fg=text_color, font=font_btn, relief="flat", width=12)

    add_button.grid(row=0, column=0, padx=5, pady=5)
    remove_button.grid(row=0, column=1, padx=5, pady=5)
    complete_button.grid(row=0, column=2, padx=5, pady=5)
    edit_button.grid(row=0, column=3, padx=5, pady=5)

    # Add secondary button frame for additional features
    action_frame = tk.Frame(root, bg=bg_color)
    action_frame.pack(pady=10)

    sort_button = tk.Button(action_frame, text="Sort by Due Date", command=lambda: sort_tasks_by_due_date_gui(task_listbox), bg=btn_color, fg=text_color, font=font_btn, relief="flat", width=18)
    filter_button = tk.Button(action_frame, text="Filter by Category", command=lambda: filter_tasks_by_category_gui(task_listbox), bg="#3498DB", fg=text_color, font=font_btn, relief="flat", width=18)
    clear_button = tk.Button(action_frame, text="Clear All Tasks", command=lambda: clear_all_tasks_gui(task_listbox), bg=accent_color, fg=text_color, font=font_btn, relief="flat", width=18)

    sort_button.grid(row=0, column=0, padx=5, pady=5)
    filter_button.grid(row=0, column=1, padx=5, pady=5)
    clear_button.grid(row=0, column=2, padx=5, pady=5)

    # Load the tasks into the listbox
    load_tasks_to_listbox(task_listbox)

    # Start the Tkinter event loop
    root.mainloop()

def load_tasks_to_listbox(listbox):
    """Load tasks from the JSON file and display them in the listbox."""
    listbox.delete(0, tk.END)  # Clear the listbox first
    try:
        with open("tasks.json", "r") as file:
            global tasks
            tasks = json.load(file)
        
        today = datetime.now()

        for task in tasks:
            # Append "(Completed)" next to completed tasks
            status = "(Completed)" if task["completed"] else ""
            
            # Check if the task is overdue and not completed
            due_date = datetime.strptime(task['due_date'], "%Y-%m-%d")
            overdue_flag = " (Overdue!)" if due_date < today and not task["completed"] else ""
            
            # Display the task with both status and overdue flag if applicable
            task_str = f"{task['name']} {status} (Priority: {task['priority']}, Due: {task['due_date']}, Category: {task.get('category', 'Uncategorized')}){overdue_flag}"
            listbox.insert(tk.END, task_str)
    except FileNotFoundError:
        messagebox.showwarning("Warning", "No tasks found. Starting fresh.")

def save_task_to_file():
    """Save the tasks to a JSON file."""
    with open("tasks.json", "w") as file:
        json.dump(tasks, file, indent=4)

def add_task_gui(listbox):
    """Add a new task via GUI."""
    def add_task():
        task_name = task_name_entry.get()
        priority = priority_var.get()
        due_date = due_date_entry.get()
        category = category_entry.get()

        try:
            datetime.strptime(due_date, "%Y-%m-%d")  # Validate the date format
            tasks.append({"name": task_name, "completed": False, "priority": priority, "due_date": due_date, "category": category})
            save_task_to_file()  # Save the new task to the file
            load_tasks_to_listbox(listbox)  # Refresh the listbox
            add_window.destroy()  # Close the add task window
        except ValueError:
            messagebox.showerror("Error", "Invalid date format. Please enter the date in YYYY-MM-DD format.")

    # Create a new window for adding a task
    add_window = tk.Toplevel()
    add_window.title("Add New Task")
    add_window.configure(bg=bg_color)
    
    tk.Label(add_window, text="Task Name", fg=text_color, bg=bg_color).pack(pady=5)
    task_name_entry = tk.Entry(add_window, font=font_default)
    task_name_entry.pack(pady=5)

    tk.Label(add_window, text="Priority (High, Medium, Low)", fg=text_color, bg=bg_color).pack(pady=5)
    priority_var = tk.StringVar(add_window)
    priority_var.set("Low")  # Default value
    priority_menu = tk.OptionMenu(add_window, priority_var, "High", "Medium", "Low")
    priority_menu.pack(pady=5)

    tk.Label(add_window, text="Due Date (YYYY-MM-DD)", fg=text_color, bg=bg_color).pack(pady=5)
    due_date_entry = tk.Entry(add_window, font=font_default)
    due_date_entry.pack(pady=5)

    tk.Label(add_window, text="Category", fg=text_color, bg=bg_color).pack(pady=5)
    category_entry = tk.Entry(add_window, font=font_default)
    category_entry.pack(pady=5)

    tk.Button(add_window, text="Add Task", command=add_task, bg=btn_color, fg=text_color, font=font_btn, relief="flat").pack(pady=10)

def remove_task_gui(listbox):
    """Remove a task based on the selected item in the listbox."""
    try:
        selected_task_index = listbox.curselection()[0]
        del tasks[selected_task_index]  # Remove from the tasks list
        save_task_to_file()  # Save changes
        load_tasks_to_listbox(listbox)  # Refresh the listbox
    except IndexError:
        messagebox.showwarning("Warning", "No task selected.")

def mark_task_complete_gui(listbox):
    """Mark a task as complete based on the selected item in the listbox."""
    try:
        selected_task_index = listbox.curselection()[0]
        tasks[selected_task_index]["completed"] = True
        save_task_to_file()  # Save changes
        load_tasks_to_listbox(listbox)  # Refresh the listbox
    except IndexError:
        messagebox.showwarning("Warning", "No task selected.")

def edit_task_gui(listbox):
    """Edit an existing task via GUI."""
    try:
        selected_task_index = listbox.curselection()[0]
        task = tasks[selected_task_index]  # Get the selected task

        def update_task():
            task['name'] = task_name_entry.get()
            task['priority'] = priority_var.get()
            task['due_date'] = due_date_entry.get()
            task['category'] = category_entry.get()

            try:
                datetime.strptime(task['due_date'], "%Y-%m-%d")  # Validate date format
                save_task_to_file()
                save_task_to_file()  # Save the updated task to the file
                load_tasks_to_listbox(listbox)  # Refresh the listbox
                edit_window.destroy()  # Close the edit task window
            except ValueError:
                messagebox.showerror("Error", "Invalid date format. Please enter the date in YYYY-MM-DD format.")

        # Create a new window for editing the task
        edit_window = tk.Toplevel()
        edit_window.title("Edit Task")
        edit_window.configure(bg=bg_color)

        tk.Label(edit_window, text="Task Name", fg=text_color, bg=bg_color).pack(pady=5)
        task_name_entry = tk.Entry(edit_window, font=font_default)
        task_name_entry.insert(0, task['name'])
        task_name_entry.pack(pady=5)

        tk.Label(edit_window, text="Priority (High, Medium, Low)", fg=text_color, bg=bg_color).pack(pady=5)
        priority_var = tk.StringVar(edit_window)
        priority_var.set(task['priority'])  # Set current priority
        priority_menu = tk.OptionMenu(edit_window, priority_var, "High", "Medium", "Low")
        priority_menu.pack(pady=5)

        tk.Label(edit_window, text="Due Date (YYYY-MM-DD)", fg=text_color, bg=bg_color).pack(pady=5)
        due_date_entry = tk.Entry(edit_window, font=font_default)
        due_date_entry.insert(0, task['due_date'])
        due_date_entry.pack(pady=5)

        tk.Label(edit_window, text="Category", fg=text_color, bg=bg_color).pack(pady=5)
        category_entry = tk.Entry(edit_window, font=font_default)
        category_entry.insert(0, task.get('category', 'Uncategorized'))
        category_entry.pack(pady=5)

        tk.Button(edit_window, text="Update Task", command=update_task, bg=btn_color, fg=text_color, font=font_btn, relief="flat").pack(pady=10)

    except IndexError:
        messagebox.showwarning("Warning", "No task selected.")

def sort_tasks_by_due_date_gui(listbox):
    """Sort tasks by due date and update the listbox."""
    sorted_tasks = sorted(tasks, key=lambda x: datetime.strptime(x['due_date'], "%Y-%m-%d"))
    tasks.clear()  # Clear the original list
    tasks.extend(sorted_tasks)  # Replace with sorted tasks
    save_task_to_file()
    load_tasks_to_listbox(listbox)

def filter_tasks_by_category_gui(listbox):
    """Filter tasks by category and update the listbox."""
    def apply_filter():
        category_filter = category_entry.get().capitalize().strip()
        filtered_tasks = [task for task in tasks if task['category'] == category_filter]
        listbox.delete(0, tk.END)
        for task in filtered_tasks:
            task_str = f"{task['name']} (Priority: {task['priority']}, Due: {task['due_date']}, Category: {task['category']})"
            listbox.insert(tk.END, task_str)
        filter_window.destroy()

    filter_window = tk.Toplevel()
    filter_window.title("Filter Tasks by Category")
    filter_window.configure(bg=bg_color)
    tk.Label(filter_window, text="Enter Category", fg=text_color, bg=bg_color).pack(pady=5)
    category_entry = tk.Entry(filter_window, font=font_default)
    category_entry.pack(pady=5)
    tk.Button(filter_window, text="Apply Filter", command=apply_filter, bg=btn_color, fg=text_color, font=font_btn, relief="flat").pack(pady=10)

def clear_all_tasks_gui(listbox):
    """Clear all tasks from the list and the file."""
    if messagebox.askyesno("Clear All Tasks", "Are you sure you want to clear all tasks? This cannot be undone."):
        tasks.clear()
        save_task_to_file()
        load_tasks_to_listbox(listbox)

# Entry point to the app
if __name__ == "__main__":
    create_gui()
