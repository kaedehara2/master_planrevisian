import 'package:flutter/material.dart';
import 'package:master_plan/models/data_layer.dart';
import 'package:master_plan/provider/plan_provider.dart';

class PlanScreen extends StatefulWidget {
  final Plan plan;
  const PlanScreen({super.key, required this.plan});

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  late ScrollController scrollController;

  Plan get plan {
    ValueNotifier<List<Plan>> plansNotifier = PlanProvider.of(context);
    return plansNotifier.value.firstWhere((p) => p.name == widget.plan.name);
  }

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController()
      ..addListener(() {
        FocusScope.of(context).requestFocus(FocusNode());
      });
  }

  @override
  Widget build(BuildContext context) {
    ValueNotifier<List<Plan>> plansNotifier = PlanProvider.of(context);

    return Scaffold(
      appBar: AppBar(
        title: ValueListenableBuilder<List<Plan>>(
          valueListenable: plansNotifier,
          builder: (context, plans, child) {
            final currentPlan = plans.firstWhere((p) => p.name == plan.name,
                orElse: () => Plan(name: 'Untitled', tasks: []));
            return Text(currentPlan.name, style: TextStyle(fontWeight: FontWeight.bold));
          },
        ),
        backgroundColor: Colors.deepPurple,
        elevation: 5,
      ),
      body: ValueListenableBuilder<List<Plan>>(
        valueListenable: plansNotifier,
        builder: (context, plans, child) {
          Plan currentPlan = plans.firstWhere(
            (p) => p.name == plan.name,
            orElse: () => Plan(name: 'Untitled', tasks: []),
          );

          return Column(
            children: [
              Expanded(child: _buildList(currentPlan)),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    currentPlan.completenessMessage,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black54),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: _buildAddTaskButton(context),
    );
  }

  Widget _buildAddTaskButton(BuildContext context) {
    ValueNotifier<List<Plan>> planNotifier = PlanProvider.of(context);
    return FloatingActionButton(
      backgroundColor: Colors.deepPurple,
      child: const Icon(Icons.add, color: Colors.white),
      onPressed: () {
        Plan currentPlan = plan;
        int planIndex =
            planNotifier.value.indexWhere((p) => p.name == currentPlan.name);
        List<Task> updatedTasks = List<Task>.from(currentPlan.tasks)
          ..add(const Task());
        planNotifier.value = List<Plan>.from(planNotifier.value)
          ..[planIndex] = Plan(
            name: currentPlan.name,
            tasks: updatedTasks,
          );
      },
    );
  }

  Widget _buildTaskTile(Task task, int index, BuildContext context) {
    ValueNotifier<List<Plan>> planNotifier = PlanProvider.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Checkbox(
              value: task.complete,
              activeColor: Colors.deepPurple,
              onChanged: (selected) {
                Plan currentPlan =
                    planNotifier.value.firstWhere((p) => p.name == plan.name);

                int planIndex = planNotifier.value
                    .indexWhere((p) => p.name == currentPlan.name);
                planNotifier.value = List<Plan>.from(planNotifier.value)
                  ..[planIndex] = Plan(
                    name: currentPlan.name,
                    tasks: List<Task>.from(currentPlan.tasks)
                      ..[index] = Task(
                        description: task.description,
                        complete: selected ?? false,
                      ),
                  );
              },
            ),
            Expanded(
              child: TextFormField(
                initialValue: task.description,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Task description',
                ),
                onChanged: (text) {
                  Plan currentPlan = plan;
                  int planIndex = planNotifier.value
                      .indexWhere((p) => p.name == currentPlan.name);
                  planNotifier.value = List<Plan>.from(planNotifier.value)
                    ..[planIndex] = Plan(
                      name: currentPlan.name,
                      tasks: List<Task>.from(currentPlan.tasks)
                        ..[index] = Task(
                          description: text,
                          complete: task.complete,
                        ),
                    );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(Plan plan) {
    return ListView.builder(
      controller: scrollController,
      itemCount: plan.tasks.length,
      itemBuilder: (context, index) =>
          _buildTaskTile(plan.tasks[index], index, context),
    );
  }
}
