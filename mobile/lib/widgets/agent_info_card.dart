import 'package:flutter/material.dart';
import '../models/user.dart';
import '../utils/constants.dart';

class AgentInfoCard extends StatelessWidget {
  final User? agent;
  final VoidCallback onContactPressed;

  const AgentInfoCard({
    Key? key,
    required this.agent,
    required this.onContactPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (agent == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text('Agent information not available'),
        ),
      );
    }

    // Determine if the image is a network image or an asset
    Widget avatarImage;
    if (agent!.imagePath.startsWith('http')) {
      avatarImage = CircleAvatar(
        backgroundImage: NetworkImage(agent!.imagePath),
        backgroundColor: Colors.grey[200],
      );
    } else {
      avatarImage = CircleAvatar(
        backgroundImage: AssetImage(agent!.imagePath),
        backgroundColor: Colors.grey[200],
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          avatarImage,
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  agent!.fullName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  'Real Estate Agent',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                if (agent!.phoneNumber.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    agent!.phoneNumber,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.chat_bubble_outline, size: 18),
              onPressed: onContactPressed,
            ),
          ),
        ],
      ),
    );
  }
}