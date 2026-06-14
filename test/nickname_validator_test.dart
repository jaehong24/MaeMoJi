import 'package:flutter_test/flutter_test.dart';

import 'package:maemoji/utils/nickname_validator.dart';

void main() {
  group('NicknameValidator', () {
    test('허용된 닉네임을 통과시킨다', () {
      expect(NicknameValidator.validate('매모지_24'), isNull);
      expect(NicknameValidator.validate('maemoji24'), isNull);
    });

    test('빈 값과 길이 제한 이유를 구분한다', () {
      expect(NicknameValidator.validate(''), '닉네임을 입력해주세요.');
      expect(
        NicknameValidator.validate('가'),
        '닉네임이 너무 짧아요. 2자 이상 입력해주세요.',
      );
      expect(
        NicknameValidator.validate('abcdefghijklmnop'),
        '닉네임이 너무 길어요. 12자 이하로 입력해주세요.',
      );
    });

    test('공백과 특수문자 제한 이유를 구분한다', () {
      expect(
        NicknameValidator.validate('매모 지'),
        '닉네임에는 띄어쓰기를 사용할 수 없어요.',
      );
      expect(
        NicknameValidator.validate('매모지!'),
        '닉네임에는 한글, 영문, 숫자, 밑줄(_)만 사용할 수 있어요.',
      );
    });
  });
}
