/// Plain-language privacy policy in the eight app languages.
class PrivacyPolicyCopy {
  const PrivacyPolicyCopy({
    required this.code,
    required this.nativeName,
    required this.title,
    required this.updated,
    required this.intro,
    required this.sections,
  });

  final String code;
  final String nativeName;
  final String title;
  final String updated;
  final String intro;
  final List<PrivacySection> sections;
}

class PrivacySection {
  const PrivacySection({required this.heading, required this.body});

  final String heading;
  final String body;
}

const kPrivacyPolicyCopies = <PrivacyPolicyCopy>[
  PrivacyPolicyCopy(
    code: 'en',
    nativeName: 'English',
    title: 'Privacy Policy',
    updated: 'Last updated: August 29, 2026',
    intro:
        'NewRoots California helps immigrant families find resources, stay safe, and connect with other newcomers in California. This page explains what information we collect and how we use it.',
    sections: [
      PrivacySection(
        heading: '1. Who we are',
        body:
            'NewRoots California (“we”) provides this app. The app helps you navigate life in California. It is not legal, medical, or financial advice.',
      ),
      PrivacySection(
        heading: '2. Information we collect',
        body:
            'Account: your email and password (through Firebase Authentication).\n\n'
            'Profile (optional): preferred language, location, family size, goals, work background, and children’s ages if you choose to share them.\n\n'
            'Support groups: groups you join, and posts, questions, replies, and photos you add. Other members of that group can see them.\n\n'
            'ScamShield: text or screenshots you ask us to check, and the result we save for you.\n\n'
            'AI help: questions you type in tools such as Roadmap, housing, jobs, and education. We send those to our server so the AI can reply in your language.\n\n'
            'App use: crash reports and basic usage so we can fix problems.\n\n'
            'We do not ask for your immigration status, Social Security number, or ID numbers. Please do not post those in groups.',
      ),
      PrivacySection(
        heading: '3. How we use it',
        body:
            'We use this information to run the app, show you nearby resources, make your roadmap, check possible scams, and keep support groups working.\n\n'
            'We do not sell your information.',
      ),
      PrivacySection(
        heading: '4. Who can see it',
        body:
            'You can see your own account, profile, and ScamShield history.\n\n'
            'Support group posts and photos are visible to members of that group. Admins may see them if we need to remove harmful content.\n\n'
            'Screenshots you upload for ScamShield are private to your account.',
      ),
      PrivacySection(
        heading: '5. Photos',
        body:
            'Photos you add to a group post are stored so other members can see them. You can delete a post you wrote. Only upload photos you have the right to share.',
      ),
      PrivacySection(
        heading: '6. Children',
        body:
            'NewRoots is for adults and families. It is not meant for children under 13 to use on their own.',
      ),
      PrivacySection(
        heading: '7. How long we keep it',
        body:
            'We keep your information while your account is open. If you delete a post or a ScamShield check, we remove it from the app. Backups may last a short time.',
      ),
      PrivacySection(
        heading: '8. Your choices',
        body:
            'You can edit your profile, leave a group, delete posts you wrote, and sign out. To delete your account and the data we store, email us.',
      ),
      PrivacySection(
        heading: '9. Contact',
        body: 'Questions about this policy: y@yunhanluo.com',
      ),
    ],
  ),
  PrivacyPolicyCopy(
    code: 'es',
    nativeName: 'Español',
    title: 'Política de privacidad',
    updated: 'Última actualización: 29 de agosto de 2026',
    intro:
        'NewRoots California ayuda a familias inmigrantes a encontrar recursos, estar más seguras y conectar con otras personas recién llegadas a California. Esta página explica qué información reunimos y cómo la usamos.',
    sections: [
      PrivacySection(
        heading: '1. Quiénes somos',
        body:
            'NewRoots California (“nosotros”) ofrece esta aplicación. La app le ayuda a orientarse en California. No es asesoría legal, médica ni financiera.',
      ),
      PrivacySection(
        heading: '2. Información que reunimos',
        body:
            'Cuenta: su correo electrónico y contraseña (a través de Firebase Authentication).\n\n'
            'Perfil (opcional): idioma preferido, ubicación, tamaño de la familia, metas, experiencia laboral y edades de los niños, si decide compartirlas.\n\n'
            'Grupos de apoyo: grupos a los que se une, y publicaciones, preguntas, respuestas y fotos que agrega. Otros miembros de ese grupo pueden verlos.\n\n'
            'ScamShield: texto o capturas de pantalla que nos pide revisar, y el resultado que guardamos para usted.\n\n'
            'Ayuda de IA: preguntas que escribe en herramientas como el plan (Roadmap), vivienda, trabajo y educación. Las enviamos a nuestro servidor para que la IA responda en su idioma.\n\n'
            'Uso de la app: reportes de fallas y uso básico para poder corregir problemas.\n\n'
            'No pedimos su estatus migratorio, número de Seguro Social ni números de identificación. Por favor no los publique en los grupos.',
      ),
      PrivacySection(
        heading: '3. Cómo la usamos',
        body:
            'Usamos esta información para operar la app, mostrarle recursos cercanos, crear su plan, revisar posibles estafas y mantener los grupos de apoyo.\n\n'
            'No vendemos su información.',
      ),
      PrivacySection(
        heading: '4. Quién puede verla',
        body:
            'Usted puede ver su cuenta, su perfil y su historial de ScamShield.\n\n'
            'Las publicaciones y fotos de un grupo las ven los miembros de ese grupo. Los administradores pueden verlas si hace falta quitar contenido dañino.\n\n'
            'Las capturas que sube a ScamShield son privadas para su cuenta.',
      ),
      PrivacySection(
        heading: '5. Fotos',
        body:
            'Las fotos que agrega a una publicación se guardan para que otros miembros las vean. Puede borrar una publicación que usted escribió. Suba solo fotos que tiene derecho a compartir.',
      ),
      PrivacySection(
        heading: '6. Niños',
        body:
            'NewRoots es para adultos y familias. No está pensada para que menores de 13 años la usen por su cuenta.',
      ),
      PrivacySection(
        heading: '7. Cuánto tiempo la guardamos',
        body:
            'Guardamos su información mientras su cuenta esté abierta. Si borra una publicación o una revisión de ScamShield, la quitamos de la app. Las copias de seguridad pueden durar un tiempo corto.',
      ),
      PrivacySection(
        heading: '8. Sus opciones',
        body:
            'Puede editar su perfil, salir de un grupo, borrar publicaciones que usted escribió y cerrar sesión. Para borrar su cuenta y los datos que guardamos, escríbanos.',
      ),
      PrivacySection(
        heading: '9. Contacto',
        body: 'Preguntas sobre esta política: y@yunhanluo.com',
      ),
    ],
  ),
  PrivacyPolicyCopy(
    code: 'zh',
    nativeName: '中文',
    title: '隐私政策',
    updated: '最近更新：2026年8月29日',
    intro:
        'NewRoots California 帮助移民家庭寻找资源、保障安全，并与加州其他新移民互相联系。本页说明我们收集哪些信息，以及如何使用这些信息。',
    sections: [
      PrivacySection(
        heading: '1. 我们是谁',
        body:
            'NewRoots California（“我们”）提供本应用。本应用帮助您在加州安顿生活。它不是法律、医疗或财务建议。',
      ),
      PrivacySection(
        heading: '2. 我们收集的信息',
        body:
            '账户：您的电子邮箱和密码（通过 Firebase Authentication）。\n\n'
            '个人资料（可选）：首选语言、所在地区、家庭人数、目标、工作背景，以及您愿意分享的孩子年龄。\n\n'
            '互助小组：您加入的小组，以及您发布的帖子、问题、回复和照片。该小组成员可以看到这些内容。\n\n'
            'ScamShield：您请我们检查的文字或截图，以及我们为您保存的结果。\n\n'
            '人工智能帮助：您在路线图、住房、工作、教育等工具中输入的问题。我们会把这些问题发送到服务器，以便人工智能用您的语言回复。\n\n'
            '应用使用情况：崩溃报告和基本使用数据，以便我们修复问题。\n\n'
            '我们不会询问您的移民身份、社会安全号或身份证号码。请不要在小组中发布这些信息。',
      ),
      PrivacySection(
        heading: '3. 我们如何使用',
        body:
            '我们使用这些信息来运行应用、向您展示附近资源、生成路线图、检查可能的诈骗，并维护互助小组。\n\n'
            '我们不会出售您的信息。',
      ),
      PrivacySection(
        heading: '4. 谁可以看到',
        body:
            '您可以查看自己的账户、个人资料和 ScamShield 记录。\n\n'
            '小组帖子和照片对该小组成员可见。如果需要删除有害内容，管理员也可能看到。\n\n'
            '您为 ScamShield 上传的截图仅您的账户可见。',
      ),
      PrivacySection(
        heading: '5. 照片',
        body:
            '您添加到帖子中的照片会保存，以便其他成员查看。您可以删除自己写的帖子。请只上传您有权分享的照片。',
      ),
      PrivacySection(
        heading: '6. 儿童',
        body: 'NewRoots 面向成年人和家庭。不适合 13 岁以下儿童单独使用。',
      ),
      PrivacySection(
        heading: '7. 保存多久',
        body:
            '只要您的账户仍然开放，我们就会保存您的信息。如果您删除帖子或 ScamShield 检查记录，我们会从应用中移除。备份可能还会保留一小段时间。',
      ),
      PrivacySection(
        heading: '8. 您的选择',
        body:
            '您可以修改个人资料、退出小组、删除自己写的帖子，以及退出登录。如需删除账户及我们保存的数据，请发邮件联系我们。',
      ),
      PrivacySection(
        heading: '9. 联系我们',
        body: '关于本政策的问题：y@yunhanluo.com',
      ),
    ],
  ),
  PrivacyPolicyCopy(
    code: 'vi',
    nativeName: 'Tiếng Việt',
    title: 'Chính sách quyền riêng tư',
    updated: 'Cập nhật lần cuối: 29 tháng 8 năm 2026',
    intro:
        'NewRoots California giúp các gia đình nhập cư tìm nguồn hỗ trợ, giữ an toàn và kết nối với người mới đến khác ở California. Trang này giải thích chúng tôi thu thập thông tin gì và cách chúng tôi sử dụng.',
    sections: [
      PrivacySection(
        heading: '1. Chúng tôi là ai',
        body:
            'NewRoots California (“chúng tôi”) cung cấp ứng dụng này. Ứng dụng giúp bạn định hướng cuộc sống ở California. Đây không phải lời khuyên pháp lý, y tế hoặc tài chính.',
      ),
      PrivacySection(
        heading: '2. Thông tin chúng tôi thu thập',
        body:
            'Tài khoản: email và mật khẩu của bạn (qua Firebase Authentication).\n\n'
            'Hồ sơ (không bắt buộc): ngôn ngữ ưa thích, nơi ở, quy mô gia đình, mục tiêu, lý lịch làm việc và tuổi của con nếu bạn muốn chia sẻ.\n\n'
            'Nhóm hỗ trợ: các nhóm bạn tham gia, cùng bài đăng, câu hỏi, trả lời và ảnh bạn thêm. Thành viên khác trong nhóm đó có thể xem.\n\n'
            'ScamShield: nội dung hoặc ảnh chụp màn hình bạn nhờ chúng tôi kiểm tra, và kết quả chúng tôi lưu cho bạn.\n\n'
            'Trợ giúp AI: câu hỏi bạn gõ trong các công cụ như Lộ trình, nhà ở, việc làm và giáo dục. Chúng tôi gửi những câu hỏi đó lên máy chủ để AI trả lời bằng ngôn ngữ của bạn.\n\n'
            'Cách dùng ứng dụng: báo cáo lỗi và mức sử dụng cơ bản để chúng tôi sửa sự cố.\n\n'
            'Chúng tôi không hỏi tình trạng nhập cư, số An sinh xã hội hoặc số giấy tờ tùy thân. Xin đừng đăng những thông tin đó trong nhóm.',
      ),
      PrivacySection(
        heading: '3. Cách chúng tôi sử dụng',
        body:
            'Chúng tôi dùng thông tin này để vận hành ứng dụng, hiện nguồn hỗ trợ gần bạn, tạo lộ trình, kiểm tra lừa đảo có thể xảy ra, và duy trì nhóm hỗ trợ.\n\n'
            'Chúng tôi không bán thông tin của bạn.',
      ),
      PrivacySection(
        heading: '4. Ai có thể xem',
        body:
            'Bạn có thể xem tài khoản, hồ sơ và lịch sử ScamShield của mình.\n\n'
            'Bài đăng và ảnh trong nhóm hiển thị cho thành viên nhóm đó. Quản trị viên có thể xem nếu cần gỡ nội dung gây hại.\n\n'
            'Ảnh chụp màn hình bạn tải lên ScamShield chỉ riêng cho tài khoản của bạn.',
      ),
      PrivacySection(
        heading: '5. Ảnh',
        body:
            'Ảnh bạn thêm vào bài đăng được lưu để thành viên khác xem. Bạn có thể xóa bài mình đã viết. Chỉ tải lên ảnh bạn có quyền chia sẻ.',
      ),
      PrivacySection(
        heading: '6. Trẻ em',
        body:
            'NewRoots dành cho người lớn và gia đình. Không dành cho trẻ dưới 13 tuổi tự sử dụng.',
      ),
      PrivacySection(
        heading: '7. Chúng tôi lưu bao lâu',
        body:
            'Chúng tôi lưu thông tin khi tài khoản của bạn còn mở. Nếu bạn xóa bài đăng hoặc một lần kiểm tra ScamShield, chúng tôi gỡ khỏi ứng dụng. Bản sao lưu có thể còn trong thời gian ngắn.',
      ),
      PrivacySection(
        heading: '8. Lựa chọn của bạn',
        body:
            'Bạn có thể sửa hồ sơ, rời nhóm, xóa bài mình đã viết và đăng xuất. Để xóa tài khoản và dữ liệu chúng tôi lưu, hãy gửi email cho chúng tôi.',
      ),
      PrivacySection(
        heading: '9. Liên hệ',
        body: 'Câu hỏi về chính sách này: y@yunhanluo.com',
      ),
    ],
  ),
  PrivacyPolicyCopy(
    code: 'ko',
    nativeName: '한국어',
    title: '개인정보 처리방침',
    updated: '최종 업데이트: 2026년 8월 29일',
    intro:
        'NewRoots California는 이민 가정이 캘리포니아에서 자원을 찾고, 안전하게 지내며, 다른 신규 이민자와 연결되도록 돕습니다. 이 페이지는 우리가 어떤 정보를 수집하고 어떻게 사용하는지 설명합니다.',
    sections: [
      PrivacySection(
        heading: '1. 운영 주체',
        body:
            'NewRoots California(이하 “우리”)가 이 앱을 제공합니다. 이 앱은 캘리포니아 생활을 안내합니다. 법률, 의료, 재정 자문이 아닙니다.',
      ),
      PrivacySection(
        heading: '2. 수집하는 정보',
        body:
            '계정: 이메일과 비밀번호(Firebase Authentication 사용).\n\n'
            '프로필(선택): 선호 언어, 거주 지역, 가족 규모, 목표, 직업 배경, 그리고 공유하기로 한 자녀 나이.\n\n'
            '지원 그룹: 가입한 그룹, 그리고 작성한 게시글, 질문, 답글, 사진. 해당 그룹의 다른 회원이 볼 수 있습니다.\n\n'
            'ScamShield: 확인해 달라고 보낸 글이나 스크린샷, 그리고 저장한 결과.\n\n'
            'AI 도움: 로드맵, 주거, 일자리, 교육 등 도구에 입력한 질문. 서버로 보내 AI가 사용 언어로 답하게 합니다.\n\n'
            '앱 사용: 문제를 고치기 위한 오류 보고와 기본 사용 정보.\n\n'
            '이민 신분, 사회보장번호, 신분증 번호는 묻지 않습니다. 그룹에 그런 정보를 올리지 마세요.',
      ),
      PrivacySection(
        heading: '3. 이용 목적',
        body:
            '이 정보는 앱 운영, 근처 자원 안내, 로드맵 작성, 사기 가능성 확인, 지원 그룹 유지에 사용합니다.\n\n'
            '우리는 정보를 판매하지 않습니다.',
      ),
      PrivacySection(
        heading: '4. 누가 볼 수 있나요',
        body:
            '본인 계정, 프로필, ScamShield 기록은 본인이 볼 수 있습니다.\n\n'
            '그룹 게시글과 사진은 그 그룹 회원에게 보입니다. 유해한 내용을 삭제해야 할 때 관리자도 볼 수 있습니다.\n\n'
            'ScamShield에 올린 스크린샷은 본인 계정에만 보입니다.',
      ),
      PrivacySection(
        heading: '5. 사진',
        body:
            '게시글에 넣은 사진은 다른 회원이 볼 수 있도록 저장됩니다. 본인이 쓴 글은 삭제할 수 있습니다. 공유할 권리가 있는 사진만 올리세요.',
      ),
      PrivacySection(
        heading: '6. 아동',
        body: 'NewRoots는 성인과 가족을 위한 서비스입니다. 13세 미만 어린이가 혼자 쓰도록 만든 앱이 아닙니다.',
      ),
      PrivacySection(
        heading: '7. 보관 기간',
        body:
            '계정이 있는 동안 정보를 보관합니다. 게시글이나 ScamShield 검사를 삭제하면 앱에서 제거합니다. 백업은 짧은 기간 남을 수 있습니다.',
      ),
      PrivacySection(
        heading: '8. 선택권',
        body:
            '프로필 수정, 그룹 탈퇴, 본인이 쓴 글 삭제, 로그아웃이 가능합니다. 계정과 저장된 데이터를 삭제하려면 이메일로 연락해 주세요.',
      ),
      PrivacySection(
        heading: '9. 문의',
        body: '이 방침에 대한 질문: y@yunhanluo.com',
      ),
    ],
  ),
  PrivacyPolicyCopy(
    code: 'hi',
    nativeName: 'हिन्दी',
    title: 'गोपनीयता नीति',
    updated: 'आखिरी अपडेट: 29 अगस्त 2026',
    intro:
        'NewRoots California आप्रवासी परिवारों को कैलिफोर्निया में संसाधन खोजने, सुरक्षित रहने और अन्य नए लोगों से जुड़ने में मदद करता है। यह पेज बताता है कि हम कौन सी जानकारी इकट्ठा करते हैं और उसका उपयोग कैसे करते हैं।',
    sections: [
      PrivacySection(
        heading: '1. हम कौन हैं',
        body:
            'NewRoots California (“हम”) यह ऐप उपलब्ध कराता है। यह ऐप कैलिफोर्निया में जीवन को समझने में मदद करता है। यह कानूनी, चिकित्सा या वित्तीय सलाह नहीं है।',
      ),
      PrivacySection(
        heading: '2. हम कौन सी जानकारी इकट्ठा करते हैं',
        body:
            'खाता: आपका ईमेल और पासवर्ड (Firebase Authentication के माध्यम से)।\n\n'
            'प्रोफ़ाइल (वैकल्पिक): पसंदीदा भाषा, स्थान, परिवार का आकार, लक्ष्य, काम का अनुभव, और बच्चों की उम्र — यदि आप उन्हें साझा करना चुनें।\n\n'
            'सहायता समूह: जिन समूहों में आप शामिल होते हैं, और आपके पोस्ट, सवाल, जवाब और फ़ोटो। उस समूह के अन्य सदस्य उन्हें देख सकते हैं।\n\n'
            'ScamShield: वह टेक्स्ट या स्क्रीनशॉट जो आप जाँच के लिए भेजते हैं, और वह परिणाम जो हम आपके लिए सहेजते हैं।\n\n'
            'एआई मदद: रोडमैप, आवास, नौकरी और शिक्षा जैसे टूल में आपके सवाल। हम उन्हें सर्वर पर भेजते हैं ताकि एआई आपकी भाषा में जवाब दे सके।\n\n'
            'ऐप का उपयोग: क्रैश रिपोर्ट और सामान्य उपयोग, ताकि हम समस्याएँ ठीक कर सकें।\n\n'
            'हम आपका इमिग्रेशन स्टेटस, सोशल सिक्योरिटी नंबर या पहचान पत्र नंबर नहीं माँगते। कृपया इन्हें समूहों में पोस्ट न करें।',
      ),
      PrivacySection(
        heading: '3. हम इसका उपयोग कैसे करते हैं',
        body:
            'हम इस जानकारी का उपयोग ऐप चलाने, पास के संसाधन दिखाने, आपका रोडमैप बनाने, संभावित धोखाधड़ी जाँचने और सहायता समूह चलाने के लिए करते हैं।\n\n'
            'हम आपकी जानकारी नहीं बेचते।',
      ),
      PrivacySection(
        heading: '4. इसे कौन देख सकता है',
        body:
            'आप अपना खाता, प्रोफ़ाइल और ScamShield इतिहास देख सकते हैं।\n\n'
            'समूह के पोस्ट और फ़ोटो उस समूह के सदस्यों को दिखते हैं। हानिकारक सामग्री हटाने के लिए एडमिन भी देख सकते हैं।\n\n'
            'ScamShield के लिए अपलोड किए गए स्क्रीनशॉट केवल आपके खाते के लिए निजी हैं।',
      ),
      PrivacySection(
        heading: '5. फ़ोटो',
        body:
            'पोस्ट में जोड़ी गई फ़ोटो इसलिए सहेजी जाती हैं ताकि अन्य सदस्य उन्हें देख सकें। आप अपना लिखा पोस्ट हटा सकते हैं। केवल वही फ़ोटो अपलोड करें जिन्हें साझा करने का आपको अधिकार है।',
      ),
      PrivacySection(
        heading: '6. बच्चे',
        body:
            'NewRoots वयस्कों और परिवारों के लिए है। यह 13 वर्ष से कम बच्चों के अकेले उपयोग के लिए नहीं है।',
      ),
      PrivacySection(
        heading: '7. हम कितने समय रखते हैं',
        body:
            'जब तक आपका खाता खुला है, हम जानकारी रखते हैं। यदि आप कोई पोस्ट या ScamShield जाँच हटाते हैं, तो हम उसे ऐप से हटा देते हैं। बैकअप थोड़े समय तक रह सकता है।',
      ),
      PrivacySection(
        heading: '8. आपके विकल्प',
        body:
            'आप अपनी प्रोफ़ाइल बदल सकते हैं, समूह छोड़ सकते हैं, अपने लिखे पोस्ट हटा सकते हैं और साइन आउट कर सकते हैं। खाता और हमारे पास मौजूद डेटा हटाने के लिए हमें ईमेल करें।',
      ),
      PrivacySection(
        heading: '9. संपर्क',
        body: 'इस नीति के बारे में सवाल: y@yunhanluo.com',
      ),
    ],
  ),
  PrivacyPolicyCopy(
    code: 'ar',
    nativeName: 'العربية',
    title: 'سياسة الخصوصية',
    updated: 'آخر تحديث: 29 أغسطس 2026',
    intro:
        'تساعد NewRoots California العائلات المهاجرة على إيجاد الموارد والبقاء بأمان والتواصل مع قادمين جدد آخرين في كاليفورنيا. توضح هذه الصفحة المعلومات التي نجمعها وكيف نستخدمها.',
    sections: [
      PrivacySection(
        heading: '1. من نحن',
        body:
            'تقدّم NewRoots California («نحن») هذا التطبيق. يساعدك التطبيق على تدبير الحياة في كاليفورنيا. وهو ليس استشارة قانونية أو طبية أو مالية.',
      ),
      PrivacySection(
        heading: '2. المعلومات التي نجمعها',
        body:
            'الحساب: بريدك الإلكتروني وكلمة المرور (عبر Firebase Authentication).\n\n'
            'الملف الشخصي (اختياري): اللغة المفضّلة، والمكان، وحجم الأسرة، والأهداف، والخلفية المهنية، وأعمار الأطفال إن اخترت مشاركتها.\n\n'
            'مجموعات الدعم: المجموعات التي تنضم إليها، والمنشورات والأسئلة والردود والصور التي تضيفها. يمكن لأعضاء تلك المجموعة رؤيتها.\n\n'
            'ScamShield: النص أو لقطات الشاشة التي تطلب فحصها، والنتيجة التي نحفظها لك.\n\n'
            'مساعدة الذكاء الاصطناعي: الأسئلة التي تكتبها في أدوات مثل خارطة الطريق والسكن والعمل والتعليم. نرسلها إلى خادمنا ليردّ الذكاء الاصطناعي بلغتك.\n\n'
            'استخدام التطبيق: تقارير الأعطال والاستخدام الأساسي لإصلاح المشكلات.\n\n'
            'لا نطلب وضعك القانوني للهجرة، ولا رقم الضمان الاجتماعي، ولا أرقام الهوية. يُرجى عدم نشرها في المجموعات.',
      ),
      PrivacySection(
        heading: '3. كيف نستخدمها',
        body:
            'نستخدم هذه المعلومات لتشغيل التطبيق، وعرض موارد قريبة، وإعداد خارطة طريقك، وفحص عمليات احتيال محتملة، وتشغيل مجموعات الدعم.\n\n'
            'نحن لا نبيع معلوماتك.',
      ),
      PrivacySection(
        heading: '4. من يمكنه رؤيتها',
        body:
            'يمكنك رؤية حسابك وملفك الشخصي وسجل ScamShield.\n\n'
            'منشورات المجموعة وصورها ظاهرة لأعضاء تلك المجموعة. قد يراها المشرفون إذا احتجنا إلى إزالة محتوى ضار.\n\n'
            'لقطات الشاشة التي ترفعها إلى ScamShield خاصة بحسابك.',
      ),
      PrivacySection(
        heading: '5. الصور',
        body:
            'تُحفظ الصور التي تضيفها إلى منشور المجموعة ليتمكن الأعضاء الآخرون من رؤيتها. يمكنك حذف منشور كتبته. ارفع فقط الصور التي يحق لك مشاركتها.',
      ),
      PrivacySection(
        heading: '6. الأطفال',
        body:
            'NewRoots مخصّص للبالغين والعائلات. وهو غير معدّ ليستخدمه الأطفال دون 13 عامًا بمفردهم.',
      ),
      PrivacySection(
        heading: '7. مدة الاحتفاظ',
        body:
            'نحتفظ بمعلوماتك ما دام حسابك مفتوحًا. إذا حذفت منشورًا أو فحص ScamShield، نزيله من التطبيق. قد تبقى النسخ الاحتياطية لفترة قصيرة.',
      ),
      PrivacySection(
        heading: '8. خياراتك',
        body:
            'يمكنك تعديل ملفك الشخصي، ومغادرة مجموعة، وحذف منشوراتك، وتسجيل الخروج. لحذف حسابك والبيانات التي نخزّنها، راسلنا بالبريد الإلكتروني.',
      ),
      PrivacySection(
        heading: '9. التواصل',
        body: 'أسئلة حول هذه السياسة: y@yunhanluo.com',
      ),
    ],
  ),
  PrivacyPolicyCopy(
    code: 'tl',
    nativeName: 'Tagalog',
    title: 'Patakaran sa Privacy',
    updated: 'Huling na-update: Agosto 29, 2026',
    intro:
        'Tumutulong ang NewRoots California sa mga pamilyang imigrante na maghanap ng resources, manatiling ligtas, at makakonekta sa ibang mga bagong dating sa California. Ipinapaliwanag ng page na ito kung anong impormasyon ang kinokolekta namin at paano namin ito ginagamit.',
    sections: [
      PrivacySection(
        heading: '1. Sino kami',
        body:
            'Ang NewRoots California (“kami”) ang nagbibigay ng app na ito. Tumutulong ang app na mag-navigate sa buhay sa California. Hindi ito payo sa batas, kalusugan, o pananalapi.',
      ),
      PrivacySection(
        heading: '2. Impormasyong kinokolekta namin',
        body:
            'Account: ang inyong email at password (sa pamamagitan ng Firebase Authentication).\n\n'
            'Profile (opsyonal): gustong wika, lokasyon, laki ng pamilya, mga layunin, background sa trabaho, at edad ng mga anak kung pipiliin ninyong ibahagi.\n\n'
            'Mga grupo ng suporta: mga grupong sinasalihan ninyo, at mga post, tanong, tugon, at larawang idinadagdag ninyo. Nakikita ito ng ibang miyembro ng grupong iyon.\n\n'
            'ScamShield: teksto o screenshot na hinihingi ninyong suriin, at ang resulta na sine-save namin para sa inyo.\n\n'
            'Tulong ng AI: mga tanong na tina-type ninyo sa mga kasangkapan tulad ng Roadmap, pabahay, trabaho, at edukasyon. Ipinapadala namin iyon sa aming server para makasagot ang AI sa inyong wika.\n\n'
            'Paggamit ng app: mga ulat ng crash at pangunahing paggamit para maayos namin ang mga problema.\n\n'
            'Hindi namin hinihingi ang inyong immigration status, Social Security number, o mga numero ng ID. Huwag i-post ang mga iyon sa mga grupo.',
      ),
      PrivacySection(
        heading: '3. Paano namin ginagamit',
        body:
            'Ginagamit namin ang impormasyong ito para patakbuhin ang app, ipakita ang resources sa malapit, gawin ang inyong roadmap, suriin ang posibleng scam, at panatilihing gumagana ang mga grupo ng suporta.\n\n'
            'Hindi namin ibinebenta ang inyong impormasyon.',
      ),
      PrivacySection(
        heading: '4. Sino ang makakakita',
        body:
            'Nakikita ninyo ang sarili ninyong account, profile, at history ng ScamShield.\n\n'
            'Nakikita ng mga miyembro ng grupo ang mga post at larawan doon. Maaaring makita ng mga admin kung kailangang alisin ang mapanganib na content.\n\n'
            'Pribado sa inyong account ang mga screenshot na ina-upload ninyo para sa ScamShield.',
      ),
      PrivacySection(
        heading: '5. Mga larawan',
        body:
            'Sine-save ang mga larawang idinadagdag ninyo sa post ng grupo para makita ng ibang miyembro. Maaari ninyong i-delete ang post na isinulat ninyo. Mag-upload lamang ng mga larawang may karapatan kayong ibahagi.',
      ),
      PrivacySection(
        heading: '6. Mga bata',
        body:
            'Ang NewRoots ay para sa mga adulto at pamilya. Hindi ito para sa mga batang wala pang 13 na taon na gagamitin nang mag-isa.',
      ),
      PrivacySection(
        heading: '7. Gaano katagal namin iniingatan',
        body:
            'Iniingatan namin ang inyong impormasyon habang bukas ang account. Kung magde-delete kayo ng post o pagsusuri sa ScamShield, inaalis namin ito sa app. Maaaring manatili ang mga backup nang maikling panahon.',
      ),
      PrivacySection(
        heading: '8. Mga pagpipilian ninyo',
        body:
            'Maaari ninyong i-edit ang profile, umalis sa grupo, i-delete ang mga post na isinulat ninyo, at mag-sign out. Para i-delete ang account at ang datos na naka-store namin, mag-email sa amin.',
      ),
      PrivacySection(
        heading: '9. Contact',
        body: 'Mga tanong tungkol sa patakarang ito: y@yunhanluo.com',
      ),
    ],
  ),
];
