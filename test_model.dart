import 'dart:convert';
import 'package:ascento_abacus/shared/models/user_model.dart';
void main() {
  const jsonStr = '''{
  "id": "c4192243-42fc-4aaf-9ed9-f1a6e3f81b10",
  "auth_id": "af279937-108e-4074-a68f-fcc5aa5bfbb2",
  "role": "student",
  "full_name": "vaibhav joshi",
  "email": "student_1783965949730@ascento.local",
  "phone": "7898030562",
  "avatar_url": "https://nlcoizgwdufrxdupgzwz.supabase.co/storage/v1/object/public/ascento-content/avatars/559d37ac-08a5-4877-b7ab-3f6cc9e523a7.jpg",
  "branch_id": null,
  "date_of_birth": "2004-09-07",
  "gender": "male",
  "address": "28 chamunda puri radha ganj road dewas",
  "is_active": true,
  "must_change_password": false,
  "fcm_token": null,
  "created_by": "b22efa54-fab7-41c9-a0ec-18beaa730822",
  "created_at": "2026-07-13T18:05:49.923782+00:00",
  "updated_at": "2026-07-13T18:32:49.581+00:00",
  "profile_image_url": null,
  "domain_id": "14a8ae32-f9f9-4b97-bd3a-d6ff261beae5",
  "qualification": null,
  "experience": null,
  "city": "dewas",
  "state": "madhya pradesh",
  "country": "india",
  "branches": null,
  "student_sections": [
    {
      "sections": {
        "name": "A",
        "classes": {
          "name": "Abacus class  Level 1"
        }
      },
      "section_id": "ef439f8a-9f1d-4847-bab2-11af49c5e65f",
      "roll_number": "12211",
      "academic_year_id": "005cb76b-0f83-4d0e-b3db-a4252b009fd9"
    }
  ]
}''';
  try {
    final user = UserModel.fromJson(jsonDecode(jsonStr));
    print('Success: ${user.name}');
  } catch (e, stack) {
    print('Error: $e');
    print(stack);
  }
}
