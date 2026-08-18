import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/active_learning_sample.dart';
import '../../services/active_learning/active_learning_queue_service.dart';

class ActiveLearningReviewScreen extends StatefulWidget {
  const ActiveLearningReviewScreen({super.key});

  @override
  State<ActiveLearningReviewScreen> createState() => _ActiveLearningReviewScreenState();
}

class _ActiveLearningReviewScreenState extends State<ActiveLearningReviewScreen> {
  final ActiveLearningQueueService _queueService = ActiveLearningQueueService();
  List<ActiveLearningSample> _samples = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSamples();
  }

  Future<void> _loadSamples() async {
    setState(() => _isLoading = true);
    final samples = await _queueService.getAllSamples();
    if (!mounted) return;
    setState(() {
      _samples = samples;
      _isLoading = false;
    });
  }

  Future<void> _syncSamples() async {
    setState(() => _isLoading = true);
    final synced = await _queueService.syncPendingSamples();
    await _loadSamples();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(synced > 0
            ? 'Successfully synced $synced sample(s) to MongoDB Atlas'
            : 'No pending samples synced (Backend offline or queue empty)'),
      ),
    );
  }

  Future<void> _deleteSample(String id) async {
    await _queueService.deleteSample(id);
    await _loadSamples();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sample removed from local queue')),
    );
  }

  void _showSampleDetails(ActiveLearningSample sample) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1F1F1F),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Sample ID: ${sample.id}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(sample.localImagePath),
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 180,
                    color: const Color(0xFF2A2A2A),
                    child: const Center(
                      child: Icon(Icons.broken_image, color: Colors.grey, size: 40),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Predicted: ${sample.predictedDisease}',
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                'Confidence: ${(sample.confidence * 100).toStringAsFixed(1)}% | Region: ${sample.regionDisplayName}',
                style: const TextStyle(color: Colors.amber, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                'Model: ${sample.modelName}',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                'Created: ${sample.timestamp.toLocal().toString().split('.')[0]}',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _deleteSample(sample.id);
                  },
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  label: const Text('Delete Sample', style: TextStyle(color: Colors.redAccent)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.redAccent),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getStatusColor(SampleSyncStatus status) {
    switch (status) {
      case SampleSyncStatus.pending:
        return Colors.amber;
      case SampleSyncStatus.synced:
        return const Color(0xFF4CAF50);
      case SampleSyncStatus.failed:
        return Colors.redAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      appBar: AppBar(
        title: const Text('Active Learning Queue'),
        backgroundColor: const Color(0xFF1F1F1F),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_upload_outlined),
            tooltip: 'Sync with MongoDB Atlas',
            onPressed: _syncSamples,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSamples,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF4CAF50)))
          : _samples.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No uncertain samples in queue',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Predictions with confidence < 80% will appear here automatically',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _samples.length,
                  itemBuilder: (context, index) {
                    final sample = _samples[index];
                    final confPercent = (sample.confidence * 100).toStringAsFixed(1);
                    final statusColor = _getStatusColor(sample.status);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1F1F1F),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.grey.shade800),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: SizedBox(
                            width: 56,
                            height: 56,
                            child: Image.file(
                              File(sample.localImagePath),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: const Color(0xFF2A2A2A),
                                child: const Icon(Icons.broken_image, color: Colors.grey, size: 24),
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          sample.predictedDisease,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'Region: ${sample.regionDisplayName}\nConf: $confPercent% • ID: ${sample.id}',
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: statusColor),
                              ),
                              child: Text(
                                sample.status.name.toUpperCase(),
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        onTap: () => _showSampleDetails(sample),
                      ),
                    );
                  },
                ),
    );
  }
}
