class Category {
  final int id;
  final String name;
  final List<CategoryChild> children;

  Category({
    required this.id,
    required this.name,
    this.children = const [],
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    // 验证 json Map 类型
    if (json == null || json is! Map<String, dynamic>) {
      return Category(id: 0, name: '');
    }

    // 验证并转换 id 字段
    int id = 0;
    if (json.containsKey('id')) {
      if (json['id'] is int) {
        id = json['id'];
      } else if (json['id'] is String) {
        try {
          id = int.parse(json['id']);
        } catch (_) {
          id = 0;
        }
      }
    }

    // 验证并转换 name 字段
    String name = '';
    if (json.containsKey('name')) {
      if (json['name'] is String) {
        name = json['name'].trim();
      } else {
        name = json['name'].toString();
      }
    }

    // 验证并转换 children 字段
    List<CategoryChild> children = [];
    if (json.containsKey('children') && json['children'] is List) {
      children = (json['children'] as List<dynamic>)
          .map((child) => CategoryChild.fromJson(child))
          .toList();
    }

    return Category(
      id: id,
      name: name,
      children: children,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'children': children.map((child) => child.toJson()).toList(),
    };
  }
}

class CategoryChild {
  final int id;
  final String name;
  final int parentId;
  final int weigh;
  final List<CategoryChild> children;

  CategoryChild({
    required this.id,
    required this.name,
    required this.parentId,
    required this.weigh,
    this.children = const [],
  });

  factory CategoryChild.fromJson(Map<String, dynamic> json) {
    // 验证 json Map 类型
    if (json == null || json is! Map<String, dynamic>) {
      return CategoryChild(id: 0, name: '', parentId: 0, weigh: 0);
    }

    // 验证并转 id 字段
    int id = 0;
    if (json.containsKey('id')) {
      if (json['id'] is int) {
        id = json['id'];
      } else if (json['id'] is String) {
        try {
          id = int.parse(json['id']);
        } catch (_) {
          id = 0;
        }
      }
    }

    // 验证并转换 name 字段
    String name = '';
    if (json.containsKey('name')) {
      if (json['name'] is String) {
        name = json['name'].trim();
      } else {
        name = json['name'].toString();
      }
    }

    // 验证并转换 parentId 字段
    int parentId = 0;
    if (json.containsKey('parent_id')) {
      if (json['parent_id'] is int) {
        parentId = json['parent_id'];
      } else if (json['parent_id'] is String) {
        try {
          parentId = int.parse(json['parent_id']);
        } catch (_) {
          parentId = 0;
        }
      }
    }

    // 验证并转换 weigh 字段
    int weigh = 0;
    if (json.containsKey('weigh')) {
      if (json['weigh'] is int) {
        weigh = json['weigh'];
      } else if (json['weigh'] is String) {
        try {
          weigh = int.parse(json['weigh']);
        } catch (_) {
          weigh = 0;
        }
      }
    }

    // 验证并转换 children 字段（递归解析三级分类）
    List<CategoryChild> children = [];
    if (json.containsKey('children') && json['children'] is List) {
      children = (json['children'] as List<dynamic>)
          .map((child) => CategoryChild.fromJson(child))
          .toList();
    }

    return CategoryChild(
      id: id,
      name: name,
      parentId: parentId,
      weigh: weigh,
      children: children,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'parent_id': parentId,
      'weigh': weigh,
      'children': children.map((child) => child.toJson()).toList(),
    };
  }
}
