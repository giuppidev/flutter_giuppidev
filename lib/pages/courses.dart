import 'package:flutter/material.dart';
import 'package:flutter_giuppidev/components/appbar.dart';
import 'package:flutter_giuppidev/main.dart';
import 'package:url_launcher/url_launcher.dart';

class CoursesPage extends StatefulWidget {
  const CoursesPage({super.key});

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  final _courses =
      supabase.from("products").select().lte("start_date", DateTime.now());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(
        title: "I corsi di giuppi<dev>",
      ),
      body: FutureBuilder(
          future: _courses,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            final courses = snapshot.data;
            return ListView.separated(
                itemCount: courses.length,
                separatorBuilder: (context, index) => const Divider(),
                padding: const EdgeInsets.all(20),
                itemBuilder: (context, index) => Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black87, width: 4),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black87,
                          spreadRadius: 1,

                          offset: Offset(4, 4), // changes position of shadow
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(10),
                      shape: const RoundedRectangleBorder(
                        side: BorderSide(width: 2, color: Colors.black87),
                      ),
                      visualDensity: VisualDensity(vertical: 3),
                      leading: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.black87, width: 2),
                          ),
                          child: Image(
                              image: NetworkImage(
                            courses[index]["cover_url"],
                          ))),
                      title: Text(
                        courses[index]['name'],
                        style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 20),
                      ),
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  CourseDetailPage(course: courses[index]))),
                    )));
          }),
    );
  }
}

class CourseDetailPage extends StatelessWidget {
  const CourseDetailPage({super.key, required this.course});
  final Map<String, dynamic> course;

  Future<void> _launcher(String ytId) async {
    Uri uri = Uri.parse("https://youtube.com/watch?v=$ytId");
    if (!await launchUrl(uri)) {
      throw Exception("Cannot launch url");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: MyAppBar(title: course["name"]),
        body: FutureBuilder(
            future: supabase
                .from("lessons")
                .select()
                .eq("product_id", course["id"])
                .order("event_timestamp", ascending: true),
            builder: ((context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              List<dynamic> lessons = snapshot.data;
              return ListView.separated(
                  itemCount: lessons.length,
                  separatorBuilder: (context, index) => const Divider(),
                  padding: const EdgeInsets.all(20),
                  itemBuilder: (context, index) => Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black87, width: 4),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black87,
                            spreadRadius: 1,

                            offset: Offset(4, 4), // changes position of shadow
                          ),
                        ],
                      ),
                      child: ListTile(
                        title: Text(
                          course["product_type"] == "masterclass"
                              ? "Masterclass"
                              : "Lezione ${index + 1}",
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w800),
                        ),
                        subtitle: Text(lessons[index]["description"]),
                        trailing: const Icon(Icons.arrow_circle_right_outlined,
                            color: Colors.black87, size: 46),
                        leading: CircleAvatar(
                            backgroundColor: const Color(0xFF6D9022),
                            child: course["product_type"] == "masterclass"
                                ? const Icon(
                                    Icons.star,
                                    color: Colors.white,
                                  )
                                : Text(
                                    (index + 1).toString(),
                                    style: const TextStyle(
                                        fontSize: 20, color: Colors.white),
                                  )),
                        onTap: () => _launcher(lessons[index]["video_yt_id"]),
                      )));
            })));
  }
}
