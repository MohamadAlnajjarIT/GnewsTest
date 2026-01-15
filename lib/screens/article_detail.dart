import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:news_reader_app/models/news_item.dart';

class ArticleDetailScreen extends StatelessWidget {
  final NewsArticle articleData;
  
  const ArticleDetailScreen({super.key, required this.articleData});

  Future<void> _openOriginalPage() async {
    try {
      final Uri url = Uri.parse(articleData.articleUrl);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      // Handle error silently
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          articleData.origin?.name ?? 'Article Details',
          style: const TextStyle(fontSize: 16),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Article image
            if (articleData.hasImage)
              Container(
                height: 220,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: NetworkImage(articleData.imageUrl!),
                    fit: BoxFit.cover,
                  ),
                ),
                margin: const EdgeInsets.only(bottom: 20),
              ),
            
            // Article title
            Text(
              articleData.headline,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Article metadata
            Row(
              children: [
                // Source
                if (articleData.origin?.name != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      articleData.origin!.name!,
                      style: TextStyle(
                        color: Colors.blue[800],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                
                const Spacer(),
                
                // Date
                Text(
                  articleData.formattedDate,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Article content
            Text(
              articleData.summary,
              style: const TextStyle(fontSize: 16, height: 1.6),
            ),
            
            const SizedBox(height: 25),
            
            // Detailed content if available
            if (articleData.detailedContent != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  const SizedBox(height: 20),
                  const Text(
                    'Full Content',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    articleData.detailedContent!,
                    style: const TextStyle(fontSize: 16, height: 1.6),
                  ),
                ],
              ),
            
            const SizedBox(height: 30),
            
            // Action button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _openOriginalPage,
                icon: const Icon(Icons.open_in_new),
                label: const Text('Read Full Article on Website'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
