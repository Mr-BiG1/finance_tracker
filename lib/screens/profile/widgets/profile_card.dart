import 'package:flutter/material.dart';
import 'package:finance_tracker/utils/constants.dart';

class ProfileCard extends StatelessWidget {
  final String userName;
  final String email;
  final String joinDate;
  final bool isVerified;
  final String? profileImageUrl;

  const ProfileCard({
    required this.userName,
    required this.email,
    required this.joinDate,
    this.isVerified = false,
    this.profileImageUrl,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.1),
            blurRadius: 12,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildProfileImage(),
          const SizedBox(height: 16),
          _buildUserName(),
          const SizedBox(height: 8),
          _buildEmailRow(),
          const SizedBox(height: 8),
          _buildJoinDate(),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.lightGrey,
        image:
            profileImageUrl != null
                ? DecorationImage(
                  image: NetworkImage(profileImageUrl!),
                  fit: BoxFit.cover,
                )
                : null,
      ),
      child:
          profileImageUrl == null
              ? const Icon(Icons.person, size: 40, color: AppColors.darkGrey)
              : null,
    );
  }

  Widget _buildUserName() {
    return Text(
      userName,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.background,
      ),
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildEmailRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            email,
            style: const TextStyle(fontSize: 14, color: AppColors.textDisabled),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (isVerified) ...[
          const SizedBox(width: 4),
          const Icon(Icons.verified, size: 16, color: AppColors.primary),
        ],
      ],
    );
  }

  Widget _buildJoinDate() {
    return Text(
      "Member since $joinDate",
      style: const TextStyle(fontSize: 12, color: AppColors.lightGrey),
    );
  }
}
