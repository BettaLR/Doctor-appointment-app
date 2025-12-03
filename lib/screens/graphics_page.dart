import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/database_service.dart';

class GraphicsPage extends StatefulWidget {
  const GraphicsPage({super.key});

  @override
  State<GraphicsPage> createState() => _GraphicsPageState();
}

class _GraphicsPageState extends State<GraphicsPage> {
  // Mint Green Theme Colors
  final Color _mintPrimary = const Color(0xFF88D8B0);
  final Color _mintSecondary = const Color(0xFFA8E6CF);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const CupertinoPageScaffold(
        child: Center(child: Text('Usuario no autenticado')),
      );
    }

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Estadísticas Médicas'),
        backgroundColor: CupertinoColors.white,
      ),
      child: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('appointments')
              .where('doctorId', isEqualTo: user.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('Error al cargar datos'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CupertinoActivityIndicator());
            }

            // Process data for charts
            final docs = snapshot.data!.docs;

            // 1. Appointments per Month
            Map<String, int> appointmentsPerMonth = {};
            for (var doc in docs) {
              final data = doc.data() as Map<String, dynamic>;
              if (data['startTime'] != null) {
                final date = DateTime.parse(data['startTime']);
                final key =
                    '${date.year}-${date.month.toString().padLeft(2, '0')}';
                appointmentsPerMonth[key] =
                    (appointmentsPerMonth[key] ?? 0) + 1;
              }
            }

            // 2. Completed vs Canceled
            int completed = 0;
            int canceled = 0;
            for (var doc in docs) {
              final data = doc.data() as Map<String, dynamic>;
              final status = data['status'];
              if (status == 'completed') completed++;
              if (status == 'cancelled') canceled++;
            }

            // 3. Patients per Doctor
            Set<String> uniquePatients = {};
            for (var doc in docs) {
              final data = doc.data() as Map<String, dynamic>;
              if (data['userId'] != null) {
                uniquePatients.add(data['userId']);
              }
            }

            Map<String, int> patientsPerDoctor = {'Yo': uniquePatients.length};

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildChartCard(
                    title: 'Citas por Mes',
                    subtitle: 'Historial de actividad mensual',
                    chart: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: appointmentsPerMonth.values.isEmpty
                            ? 10
                            : appointmentsPerMonth.values
                                      .reduce((a, b) => a > b ? a : b)
                                      .toDouble() +
                                  2,
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData: BarTouchTooltipData(
                            tooltipBgColor: _mintPrimary,
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              return BarTooltipItem(
                                rod.toY.round().toString(),
                                const TextStyle(
                                  color: CupertinoColors.white,
                                  fontWeight: FontWeight.bold,
                                  inherit: false,
                                  fontFamily: '.SF Pro Text',
                                ),
                              );
                            },
                          ),
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                const months = [
                                  'Ene',
                                  'Feb',
                                  'Mar',
                                  'Abr',
                                  'May',
                                  'Jun',
                                  'Jul',
                                  'Ago',
                                  'Sep',
                                  'Oct',
                                  'Nov',
                                  'Dic',
                                ];
                                if (value < 1 || value > 12)
                                  return const Text('');
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    months[value.toInt() - 1],
                                    style: const TextStyle(
                                      color: CupertinoColors.systemGrey,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      inherit: false,
                                      fontFamily: '.SF Pro Text',
                                    ),
                                  ),
                                );
                              },
                              reservedSize: 30,
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              getTitlesWidget: (value, meta) {
                                if (value % 1 != 0) return const Text('');
                                return Text(
                                  value.toInt().toString(),
                                  style: const TextStyle(
                                    color: CupertinoColors.systemGrey,
                                    fontSize: 12,
                                    inherit: false,
                                    fontFamily: '.SF Pro Text',
                                  ),
                                );
                              },
                            ),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: 1,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: CupertinoColors.systemGrey5,
                              strokeWidth: 1,
                            );
                          },
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: appointmentsPerMonth.entries.map((entry) {
                          return BarChartGroupData(
                            x: int.parse(entry.key.split('-')[1]),
                            barRods: [
                              BarChartRodData(
                                toY: entry.value.toDouble(),
                                color: _mintPrimary,
                                width: 16,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(6),
                                  topRight: Radius.circular(6),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildChartCard(
                    title: 'Estado de Citas',
                    subtitle: 'Proporción de completadas vs canceladas',
                    chart: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        sections: [
                          PieChartSectionData(
                            value: completed.toDouble(),
                            title: '$completed\nCompletadas',
                            titleStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: CupertinoColors.white,
                              inherit: false,
                              fontFamily: '.SF Pro Text',
                            ),
                            color: _mintPrimary,
                            radius: 60,
                          ),
                          PieChartSectionData(
                            value: canceled.toDouble(),
                            title: '$canceled\nCanceladas',
                            titleStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: CupertinoColors.white,
                              inherit: false,
                              fontFamily: '.SF Pro Text',
                            ),
                            color: CupertinoColors.systemRed.withOpacity(0.7),
                            radius: 60,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildChartCard(
                    title: 'Mis Pacientes',
                    subtitle: 'Total de pacientes únicos atendidos',
                    chart: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: patientsPerDoctor.values.isEmpty
                            ? 10
                            : patientsPerDoctor.values
                                      .reduce((a, b) => a > b ? a : b)
                                      .toDouble() +
                                  2,
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData: BarTouchTooltipData(
                            tooltipBgColor: _mintSecondary,
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              return BarTooltipItem(
                                rod.toY.round().toString(),
                                const TextStyle(
                                  color: CupertinoColors.black,
                                  fontWeight: FontWeight.bold,
                                  inherit: false,
                                  fontFamily: '.SF Pro Text',
                                ),
                              );
                            },
                          ),
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    'Total',
                                    style: const TextStyle(
                                      color: CupertinoColors.systemGrey,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      inherit: false,
                                      fontFamily: '.SF Pro Text',
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              getTitlesWidget: (value, meta) {
                                if (value % 1 != 0) return const Text('');
                                return Text(
                                  value.toInt().toString(),
                                  style: const TextStyle(
                                    color: CupertinoColors.systemGrey,
                                    fontSize: 12,
                                    inherit: false,
                                    fontFamily: '.SF Pro Text',
                                  ),
                                );
                              },
                            ),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: 1,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: CupertinoColors.systemGrey5,
                              strokeWidth: 1,
                            );
                          },
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: patientsPerDoctor.entries.map((entry) {
                          return BarChartGroupData(
                            x: 0,
                            barRods: [
                              BarChartRodData(
                                toY: entry.value.toDouble(),
                                color: _mintSecondary,
                                width: 32,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(6),
                                  topRight: Radius.circular(6),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildChartCard({
    required String title,
    required String subtitle,
    required Widget chart,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: CupertinoColors.black,
                inherit: false,
                fontFamily: '.SF Pro Display',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: CupertinoColors.systemGrey,
                inherit: false,
                fontFamily: '.SF Pro Text',
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(height: 250, child: chart),
          ],
        ),
      ),
    );
  }
}
