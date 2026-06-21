import 'lesson_model.dart';

class CourseModel {
  final String id;
  final String title;
  final String instructor;
  final String description;
  final double rating;
  final String thumbnail;
  final double price;
  final bool isFree;
  final bool isPopular;
  final List<LessonModel> lessons;

  CourseModel({
    required this.id,
    required this.title,
    required this.instructor,
    required this.description,
    required this.rating,
    required this.thumbnail,
    required this.price,
    required this.isFree,
    required this.isPopular,
    required this.lessons,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    var lessonsList = json['lessons'] as List?;
    List<LessonModel> parsedLessons = lessonsList != null
        ? lessonsList.map((i) => LessonModel.fromJson(i as Map<String, dynamic>)).toList()
        : [];

    // Provide default lessons if empty for UI details
    if (parsedLessons.isEmpty) {
      parsedLessons = [
        LessonModel(id: '1', title: 'Introduction to the Course', duration: '05:30'),
        LessonModel(id: '2', title: 'Core Concepts & Setup', duration: '12:15'),
        LessonModel(id: '3', title: 'Hands-on Practice Session', duration: '18:45'),
        LessonModel(id: '4', title: 'Advanced Topics', duration: '22:00'),
        LessonModel(id: '5', title: 'Summary & Next Steps', duration: '08:10'),
      ];
    }

    // Adapt fields from typical products API if used
    String title = json['title'] ?? json['name'] ?? 'Untitled Course';
    String instructor = json['instructor'] ?? 'Dr. Alex Stone';
    String desc = json['description'] ?? 'Learn how to master this subject step-by-step with real-world examples.';
    double ratingVal = 4.5;
    if (json['rating'] != null) {
      if (json['rating'] is Map) {
        ratingVal = double.tryParse(json['rating']['rate']?.toString() ?? '4.5') ?? 4.5;
      } else {
        ratingVal = double.tryParse(json['rating'].toString()) ?? 4.5;
      }
    }
    double priceVal = double.tryParse(json['price']?.toString() ?? '0.0') ?? 0.0;
    String img = json['image'] ?? json['thumbnail'] ?? 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?q=80&w=600&auto=format&fit=crop';

    // Map clothes and accessories to real courses if they come from FakeStoreAPI
    if (json['category'] != null) {
      final category = json['category'].toString().toLowerCase();
      final idStr = json['id']?.toString() ?? '';
      final idInt = int.tryParse(idStr) ?? 0;
      
      // Determine course price: make some free (priceVal = 0.0) or set standard pricing ranges
      if (idInt % 4 == 0) {
        priceVal = 0.0; // Free Course
      } else {
        priceVal = 29.99 + (idInt * 10) % 150; // Course price range: $29.99 to $179.99
      }

      if (category.contains('electronics')) {
        title = _getElectronicsTitle(idInt);
        instructor = _getElectronicsInstructor(idInt);
        img = _getElectronicsImage(idInt);
        desc = _getElectronicsDescription(idInt);
      } else if (category.contains('jewelery')) {
        title = _getJewelryTitle(idInt);
        instructor = _getJewelryInstructor(idInt);
        img = _getJewelryImage(idInt);
        desc = _getJewelryDescription(idInt);
      } else if (category.contains('clothing')) {
        title = _getClothingTitle(idInt);
        instructor = _getClothingInstructor(idInt);
        img = _getClothingImage(idInt);
        desc = _getClothingDescription(idInt);
      }
    }

    return CourseModel(
      id: json['id']?.toString() ?? DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      instructor: instructor,
      description: desc,
      rating: ratingVal,
      thumbnail: img,
      price: priceVal,
      isFree: priceVal == 0.0 || (json['isFree'] == true),
      isPopular: priceVal > 50.0 || (json['isPopular'] == true) || ratingVal >= 4.5,
      lessons: parsedLessons,
    );
  }

  static String _getElectronicsTitle(int id) {
    switch (id % 5) {
      case 0: return 'Complete Embedded Systems & Arduino Bootcamp';
      case 1: return 'Mobile Application Security & Penetration Testing';
      case 2: return 'Introduction to Quantum Computing & Logic';
      case 3: return 'Raspberry Pi: Build Smart IoT Devices';
      default: return 'Advanced Circuit Design & PCB Layout';
    }
  }

  static String _getElectronicsInstructor(int id) {
    switch (id % 3) {
      case 0: return 'Prof. Harold Finch';
      case 1: return 'Dr. Raymond Palmer';
      default: return 'Sarah Connor, MSc';
    }
  }

  static String _getElectronicsImage(int id) {
    switch (id % 4) {
      case 0: return 'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?q=80&w=400';
      case 1: return 'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?q=80&w=400';
      case 2: return 'https://images.unsplash.com/photo-1635070041078-e363dbe005cb?q=80&w=400';
      default: return 'https://images.unsplash.com/photo-1518770660439-4636190af475?q=80&w=400';
    }
  }

  static String _getJewelryTitle(int id) {
    switch (id % 4) {
      case 0: return '3D Jewelry Design & CAD Modeling in Rhino';
      case 1: return 'The Art of Metal Clay & Goldsmithing';
      case 2: return 'Gemology Fundamentals: Identifications & Valuation';
      default: return 'UI/UX Design Masterclass: Crafting Elegant Portfolios';
    }
  }

  static String _getJewelryInstructor(int id) {
    return 'Elena Vance, Senior Designer';
  }

  static String _getJewelryImage(int id) {
    switch (id % 3) {
      case 0: return 'https://images.unsplash.com/photo-1586717791821-3f44a563fa4c?q=80&w=400';
      case 1: return 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?q=80&w=400';
      default: return 'https://images.unsplash.com/photo-1513519245088-0e12902e5a38?q=80&w=400';
    }
  }

  static String _getClothingTitle(int id) {
    switch (id % 6) {
      case 0: return 'Fashion Design Masterclass: Concept to Runway';
      case 1: return 'Digital Illustration for Apparel & Textiles';
      case 2: return 'Complete Tailoring & Custom Garment Alteration';
      case 3: return 'The Business of Fashion: Build Your Own Label';
      case 4: return 'Knitting & Fiber Arts for Absolute Beginners';
      default: return 'Sustainable Textiles & Eco-Friendly Design';
    }
  }

  static String _getClothingInstructor(int id) {
    switch (id % 3) {
      case 0: return 'Stella McCartney, Fashion Lead';
      case 1: return 'Prof. Tim Gunn';
      default: return 'Coco Chanel, Design Expert';
    }
  }

  static String _getClothingImage(int id) {
    switch (id % 4) {
      case 0: return 'https://images.unsplash.com/photo-1512436991641-6745cdb1723f?q=80&w=400';
      case 1: return 'https://images.unsplash.com/photo-1490481651871-ab68de25d43d?q=80&w=400';
      case 2: return 'https://images.unsplash.com/photo-1524253482453-3fed8d2fe12b?q=80&w=400';
      default: return 'https://images.unsplash.com/photo-1489987707025-afc232f7ea0f?q=80&w=400';
    }
  }

  static String _getElectronicsDescription(int id) {
    switch (id % 5) {
      case 0:
        return 'Learn how to program microcontroller chips and build custom physical electronics circuits using the Arduino platform from scratch.';
      case 1:
        return 'Learn the core principles of securing Android and iOS apps, performing static/dynamic analysis, and identifying common vulnerabilities.';
      case 2:
        return 'Explore the math, logic gates, and programming paradigms behind quantum computing, and code your first algorithms using Qiskit.';
      case 3:
        return 'Unlock the potential of Raspberry Pi. Set up your microcomputer, connect sensors, code in Python, and build interactive internet-of-things devices.';
      default:
        return 'Master industrial-grade circuit design, schematic capture, component selection, and multi-layer printed circuit board (PCB) layouts.';
    }
  }

  static String _getJewelryDescription(int id) {
    switch (id % 4) {
      case 0:
        return 'Learn how to model precise ring, earring, and pendant designs in 3D using Rhino CAD. Perfect for rendering and 3D printing preparation.';
      case 1:
        return 'Discover how to shape, fire, and finish precious metal clay (PMC) into stunning solid silver and gold jewelry pieces from home.';
      case 2:
        return 'Master the science of analyzing gemstones. Learn to identify diamonds, rubies, sapphires, and emeralds using professional gemological tools.';
      default:
        return 'A comprehensive masterclass on design systems, user journeys, responsive layouts, and prototyping to build a high-converting design portfolio.';
    }
  }

  static String _getClothingDescription(int id) {
    switch (id % 6) {
      case 0:
        return 'Develop your personal aesthetic, learn pattern-making, draping, and fashion illustration to compile a complete runway collection.';
      case 1:
        return 'Master digital drawing tools like Adobe Illustrator and Photoshop to create seamless repeat patterns and clothing CAD sketches.';
      case 2:
        return 'Learn professional hand-sewing, machine-stitching, pattern adjustment, and resizing techniques for bespoke tailored suits and dresses.';
      case 3:
        return 'A complete guide to sourcing fabrics, manufacturing, branding, pricing, marketing, and selling your apparel collection online.';
      case 4:
        return 'Learn cast-on, knit, purl, and bind-off stitches. Complete simple projects like scarves, hats, and mittens with confidence.';
      default:
        return 'Explore organic fibers, natural dyes, circular fashion practices, and sustainable design choices for building an ethical apparel brand.';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'instructor': instructor,
      'description': description,
      'rating': rating,
      'thumbnail': thumbnail,
      'price': price,
      'isFree': isFree,
      'isPopular': isPopular,
      'lessons': lessons.map((l) => l.toJson()).toList(),
    };
  }
}
