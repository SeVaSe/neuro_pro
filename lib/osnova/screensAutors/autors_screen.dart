import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';  // Импортируем url_launcher

import '../../assets/colors/app_colors.dart';

class AuthorsScreen extends StatelessWidget {
  final List<Author> authors = [
    Author(
      fullName: "Табе Евгения",
      photoUrl: "lib/assets/imgs/imgAutorDoctor.png",  // Локальный путь
      title: "Руководитель",
      bio: "Врач травматолог-ортопед, Кандидат медицинских наук",
      projectRole: "Создатель идеи проекта, эксперт. Разработала концепцию, участвовала в проектировании, консультировала по медицинским вопросам, формулировала медицинские термины, давала рекомендации по улучшению функционала и определяла направление развития приложения. Руководила этапами разработки",
      position: "Руководитель проекта",
      interests: "ДЦП, Орфанная патология, Состояния после инсультов",
      socialLinks: {
        'website': "https://drtabe.ukit.me",  // Сайт
        'telegram': "https://t.me/doctor_tabe",  // Телеграм
        'email': "dr.tabe@mail.ru",  // Почта
        'vk': "https://vk.com/e.tabe", // ВКонтакте
      },
    ),
    Author(
      fullName: "Севастьянов Константин",
      photoUrl: "lib/assets/imgs/imgAutorProgrammer.png",  // Локальный путь
      title: "Разработчик",
      bio: "Инженер-программист",
      projectRole: "Разработчик приложения, технический архитектор. Полностью реализовал техническую часть проекта, включая разработку структуры приложения, написание кода и оптимизацию работы. Участвовал в проектировании, предлагал и внедрял новые идеи, обеспечивал стабильность и безопасность системы",
      position: "Разработчик",
      interests: "Системное программирование, Computer vision, Мобильная разработка",
      socialLinks: {
        'website': "https://sevase.github.io/sevasek/",  // Сайт
        'telegram': "https://t.me/sevasek",  // Телеграм
        'email': "sevasek.inter@gmail.com"  // Почта
      },
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Наши авторы", style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'TinosBold',)),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.thirdColor,
      ),
      body: ListView.builder(
        itemCount: authors.length,
        itemBuilder: (context, index) {
          final author = authors[index];
          return AuthorCard(author: author);
        },
      ),
    );
  }
}

class Author {
  final String fullName;
  final String photoUrl;
  final String title;
  final String bio;
  final String projectRole;
  final String position;
  final String interests;
  final Map<String, String> socialLinks;

  Author({
    required this.fullName,
    required this.photoUrl,
    required this.title,
    required this.bio,
    required this.projectRole,
    required this.position,
    required this.interests,
    required this.socialLinks,
  });
}

class AuthorCard extends StatefulWidget {
  final Author author;

  AuthorCard({required this.author});

  @override
  _AuthorCardState createState() => _AuthorCardState();
}

class _AuthorCardState extends State<AuthorCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Card(
      margin: EdgeInsets.symmetric(
        vertical: 10,
        horizontal: screenWidth * 0.05,
      ),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      shadowColor: Colors.black54,
      color: Colors.white,
      child: Column(
        children: [
          ListTile(
            contentPadding: EdgeInsets.symmetric(
              vertical: 10,
              horizontal: screenWidth * 0.05,
            ),
            leading: CircleAvatar(
              radius: screenWidth * 0.1,
              backgroundImage: AssetImage(widget.author.photoUrl),
            ),
            title: Text(
              widget.author.fullName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: screenWidth * 0.05,
                color: AppColors.secondryColor,
              ),
            ),
            subtitle: Text(
              widget.author.title,
              style: TextStyle(color: Colors.grey[600]),
            ),
            trailing: IconButton(
              icon: Icon(
                _isExpanded ? Icons.expand_less : Icons.expand_more,
                color: AppColors.secondryColor,
              ),
              onPressed: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
            ),
          ),
          AnimatedCrossFade(
            duration: Duration(milliseconds: 300),
            firstChild: Container(),
            secondChild: Padding(
              padding: EdgeInsets.all(screenWidth * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection("О себе", widget.author.bio, screenWidth),
                  _buildSection("Роль в проекте", widget.author.projectRole, screenWidth),
                  _buildSection("Сфера интересов", widget.author.interests, screenWidth),
                  _buildSocialLinks(widget.author.socialLinks, screenWidth),
                ],
              ),
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content, double screenWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: screenWidth * 0.04,
            fontWeight: FontWeight.bold,
            color: AppColors.secondryColor,
          ),
        ),
        SizedBox(height: 8),
        Text(
          content,
          style: TextStyle(
            fontSize: screenWidth * 0.035,
            color: AppColors.text2Color,
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSocialLinks(Map<String, String> socialLinks, double screenWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Контакты:",
          style: TextStyle(
            fontSize: screenWidth * 0.04,
            fontWeight: FontWeight.bold,
            color: AppColors.secondryColor,
          ),
        ),
        Row(
          children: socialLinks.entries.map((entry) {
            return Padding(
              padding: EdgeInsets.only(right: screenWidth * 0.05),
              child: Column(
                children: [
                  IconButton(
                    icon: Icon(
                      _getSocialIcon(entry.key),
                      color: AppColors.primaryColor,
                    ),
                    onPressed: () {
                      _launchURL(entry.value);
                    },
                  ),
                  Text(
                    _getSocialLabel(entry.key),
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontSize: screenWidth * 0.03,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  IconData _getSocialIcon(String type) {
    switch (type) {
      case 'website':
        return Icons.language;
      case 'telegram':
        return Icons.telegram;
      case 'email':
        return Icons.email;
      case 'vk':  // Добавлен контакт ВК
        return Icons.group;
      default:
        return Icons.link;
    }
  }

  String _getSocialLabel(String type) {
    switch (type) {
      case 'website':
        return 'Сайт';
      case 'telegram':
        return 'Telegram';
      case 'email':
        return 'Почта';
      case 'vk':  // Добавлен контакт ВК
        return 'ВКонтакте';
      default:
        return 'Ссылка';
    }
  }

  void _launchURL(String url) async {
    // Если ссылка не содержит 'mailto:', добавляем его
    if (!url.startsWith('mailto:') && url.contains('@')) {
      url = 'mailto:' + url;
    }

    final Uri uri = Uri.parse(url);

    try {
      await launchUrl(uri);
    } catch (e) {
      print('Ошибка при открытии ссылки: $e');
    }
  }
}
