import 'package:flutter/material.dart';

import '../models/risk_profile_result.dart';
import '../services/auth_session_store.dart';
import '../services/risk_profile_service.dart';
import '../theme/app_theme.dart';
import 'app_shell.dart';

class InvestmentDnaSurveyScreen extends StatefulWidget {
  const InvestmentDnaSurveyScreen({
    super.key,
    this.source = 'ONBOARDING_SURVEY',
    this.contextLabel = '첫 설문',
  });

  final String source;
  final String contextLabel;

  @override
  State<InvestmentDnaSurveyScreen> createState() =>
      _InvestmentDnaSurveyScreenState();
}

class _InvestmentDnaSurveyScreenState extends State<InvestmentDnaSurveyScreen> {
  final PageController _pageController = PageController();
  final RiskProfileService _riskProfileService = RiskProfileService();
  final List<int?> _answers = List<int?>.filled(_questions.length, null);

  int _currentIndex = 0;
  bool _submitting = false;
  String? _errorMessage;
  RiskProfileResult? _result;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;
    if (result != null) {
      return _ResultView(
        result: result,
        onContinue: _openApp,
        contextLabel: widget.contextLabel,
      );
    }

    final progress = (_currentIndex + 1) / _questions.length;
    return Scaffold(
      backgroundColor: MaeMojiColors.paper,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (_currentIndex > 0)
                        IconButton(
                          onPressed: _submitting ? null : _previousQuestion,
                          icon: const Icon(Icons.arrow_back_rounded),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 42,
                            minHeight: 42,
                          ),
                        ),
                      if (_currentIndex > 0) const SizedBox(width: 4),
                      const Expanded(
                        child: Text(
                          '나의 투자 DNA 찾기',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.6,
                            color: MaeMojiColors.ink,
                          ),
                        ),
                      ),
                      Text(
                        '${_currentIndex + 1} / ${_questions.length}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: MaeMojiColors.inkMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 7,
                      backgroundColor: MaeMojiColors.paperDeep,
                      color: MaeMojiColors.ink,
                    ),
                  ),
                  if (_currentIndex == 0) ...[
                    const SizedBox(height: 12),
                    const Text(
                      '당신은 돈을 어떻게 생각하는 사람일까요?',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: MaeMojiColors.inkSoft,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      '정답은 없어요. 실제 내 모습에 가까운 답을 골라주세요.',
                      style: TextStyle(
                        fontSize: 12,
                        color: MaeMojiColors.inkMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _questions.length,
                itemBuilder: (context, index) {
                  return _QuestionPage(
                    question: _questions[index],
                    selectedScore: _answers[index],
                    onSelected: _submitting
                        ? null
                        : (score) {
                            setState(() {
                              _answers[index] = score;
                              _errorMessage = null;
                            });
                          },
                  );
                },
              ),
            ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 10),
                child: Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: MaeMojiColors.stop,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 8, 22, 20),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton(
                  onPressed: _answers[_currentIndex] == null || _submitting
                      ? null
                      : _next,
                  style: FilledButton.styleFrom(
                    backgroundColor: MaeMojiColors.ink,
                    disabledBackgroundColor: MaeMojiColors.paperDeep,
                    foregroundColor: Colors.white,
                    disabledForegroundColor: MaeMojiColors.inkMuted,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: _submitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          _currentIndex == _questions.length - 1
                              ? '나의 투자 DNA 확인하기'
                              : '다음 질문',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _next() async {
    if (_currentIndex < _questions.length - 1) {
      setState(() => _currentIndex++);
      await _pageController.nextPage(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
      );
      return;
    }

    await _submit();
  }

  Future<void> _previousQuestion() async {
    if (_currentIndex == 0) {
      return;
    }
    setState(() => _currentIndex--);
    await _pageController.previousPage(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _submit() async {
    final answers = _answers.whereType<int>().toList();
    if (answers.length != _questions.length) {
      setState(() => _errorMessage = '모든 질문에 답해주세요.');
      return;
    }

    setState(() {
      _submitting = true;
      _errorMessage = null;
    });

    try {
      final result = await _riskProfileService.submitSurvey(
        answers,
        source: widget.source,
      );
      final session = AuthSessionStore.instance.session;
      if (session != null) {
        final updatedUser = session.user.copyWith(
          riskProfile: result.riskProfile,
          investmentDnaType: result.investmentDnaType,
          riskProfileScore: result.score,
          riskProfileConfidence: 100,
          riskProfileSource: widget.source,
        );
        await AuthSessionStore.instance.save(
          session.copyWith(user: updatedUser),
        );
      }
      if (mounted) {
        setState(() => _result = result);
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _errorMessage = error.toString().replaceFirst('Exception: ', '');
        });
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  void _openApp() {
    if (widget.source == 'MANUAL_UPDATE') {
      Navigator.of(context).pop(_result);
      return;
    }
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AppShell()),
      (route) => false,
    );
  }
}

class _QuestionPage extends StatelessWidget {
  const _QuestionPage({
    required this.question,
    required this.selectedScore,
    required this.onSelected,
  });

  final _SurveyQuestion question;
  final int? selectedScore;
  final ValueChanged<int>? onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 16, 22, 12),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question.situation,
              style: const TextStyle(
                fontSize: 25,
                height: 1.32,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.7,
                color: MaeMojiColors.ink,
              ),
            ),
            if (question.prompt.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                question.prompt,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.45,
                  fontWeight: FontWeight.w600,
                  color: MaeMojiColors.inkSoft,
                ),
              ),
            ],
            const SizedBox(height: 24),
            for (var index = 0; index < question.options.length; index++) ...[
              _AnswerTile(
                label: String.fromCharCode(65 + index),
                text: question.options[index],
                selected: selectedScore == index + 1,
                onTap: onSelected == null ? null : () => onSelected!(index + 1),
              ),
              if (index < question.options.length - 1)
                const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}

class _AnswerTile extends StatelessWidget {
  const _AnswerTile({
    required this.label,
    required this.text,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String text;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFFFFF1D8) : Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? const Color(0xFFD59B45) : MaeMojiColors.stroke,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? MaeMojiColors.ink : MaeMojiColors.paperSoft,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: selected ? Colors.white : MaeMojiColors.inkSoft,
                  ),
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                    color: MaeMojiColors.ink,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                selected ? Icons.check_circle_rounded : Icons.circle_outlined,
                size: 21,
                color: selected
                    ? const Color(0xFFB77723)
                    : MaeMojiColors.stroke,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultView extends StatelessWidget {
  const _ResultView({
    required this.result,
    required this.onContinue,
    required this.contextLabel,
  });

  final RiskProfileResult result;
  final VoidCallback onContinue;
  final String contextLabel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MaeMojiColors.paper,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 28),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '당신의 투자 DNA',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: MaeMojiColors.inkMuted,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '당신은 ${result.title}입니다.',
                    style: const TextStyle(
                      fontSize: 29,
                      height: 1.25,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.9,
                      color: MaeMojiColors.ink,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$contextLabel · ${result.score}점 · 60점',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFB77723),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: MaeMojiColors.stroke),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          result.summary,
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.55,
                            fontWeight: FontWeight.w700,
                            color: MaeMojiColors.ink,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          result.preference,
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.55,
                            color: MaeMojiColors.inkSoft,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    '참고 자산 배분',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: MaeMojiColors.ink,
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (final entry in result.suggestedAllocation.entries) ...[
                    _AllocationBar(label: entry.key, percent: entry.value),
                    const SizedBox(height: 11),
                  ],
                  const SizedBox(height: 10),
                  const Text(
                    '이 결과는 투자성향을 이해하기 위한 참고 정보이며 투자 권유가 아니에요.',
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.45,
                      color: MaeMojiColors.inkMuted,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: FilledButton(
                      onPressed: onContinue,
                      style: FilledButton.styleFrom(
                        backgroundColor: MaeMojiColors.ink,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: const Text(
                        '매모지 시작하기',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AllocationBar extends StatelessWidget {
  const _AllocationBar({required this.label, required this.percent});

  final String label;
  final int percent;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: MaeMojiColors.inkSoft,
                ),
              ),
            ),
            Text(
              '$percent%',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: MaeMojiColors.ink,
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: percent / 100,
            minHeight: 8,
            backgroundColor: MaeMojiColors.paperDeep,
            color: const Color(0xFFD59B45),
          ),
        ),
      ],
    );
  }
}

class _SurveyQuestion {
  const _SurveyQuestion({
    required this.situation,
    required this.prompt,
    required this.options,
  });

  final String situation;
  final String prompt;
  final List<String> options;
}

const List<_SurveyQuestion> _questions = [
  _SurveyQuestion(
    situation: '예상치 못하게 300만 원이 생겼습니다.',
    prompt: '가장 먼저 할 행동은?',
    options: [
      '사고 싶었던 물건이나 여행에 사용한다.',
      '가족, 친구와 맛있는 것을 먹으며 즐긴다.',
      '예금이나 적금에 넣어둔다.',
      'ETF나 우량주를 매수한다.',
      '성장주나 고위험 자산에 투자한다.',
    ],
  ),
  _SurveyQuestion(
    situation: '주식 앱을 열었는데 보유 종목이 -25%입니다.',
    prompt: '당신의 반응은?',
    options: [
      '바로 매도한다.',
      '손절을 고민한다.',
      '일단 지켜본다.',
      '추가 매수를 검토한다.',
      '오히려 매수 기회라고 생각한다.',
    ],
  ),
  _SurveyQuestion(
    situation: '신형 스마트폰이 출시되었습니다.',
    prompt: '현재 폰은 문제없이 작동합니다. 당신은?',
    options: [
      '바로 구매한다.',
      '몇 달 후 할인하면 산다.',
      '지금 폰을 더 사용한다.',
      '배터리가 안 좋아질 때까지 사용한다.',
      '투자할 돈이 줄어드니 구매를 미룬다.',
    ],
  ),
  _SurveyQuestion(
    situation: '친구가 “이 종목 10배 간다”며 추천합니다.',
    prompt: '당신은?',
    options: [
      '바로 매수한다.',
      '소액만 투자한다.',
      '검색해본다.',
      '재무제표와 사업 내용을 본다.',
      '검증되지 않은 종목은 투자하지 않는다.',
    ],
  ),
  _SurveyQuestion(
    situation: '월급이 들어왔습니다.',
    prompt: '가장 먼저 하는 행동은?',
    options: [
      '사고 싶었던 것을 산다.',
      '카드값과 생활비를 정리한다.',
      '저축부터 한다.',
      '투자금을 먼저 분리한다.',
      '자동 투자 설정이 이미 되어 있다.',
    ],
  ),
  _SurveyQuestion(
    situation: '당신에게 1억 원이 있다면?',
    prompt: '',
    options: [
      '집, 차, 여행 등 원하는 것부터 한다.',
      '일부 소비하고 일부 저축한다.',
      '대부분 안전자산에 넣는다.',
      'ETF 중심으로 투자한다.',
      '적극적으로 포트폴리오를 구성한다.',
    ],
  ),
  _SurveyQuestion(
    situation: '연 30% 수익을 기대할 수 있지만 손실 가능성도 큰 상품이 있습니다.',
    prompt: '당신은?',
    options: [
      '절대 투자하지 않는다.',
      '조금만 투자한다.',
      '고민해본다.',
      '일부 비중으로 투자한다.',
      '높은 비중으로 투자한다.',
    ],
  ),
  _SurveyQuestion(
    situation: '복권 1등에 당첨되었습니다.',
    prompt: '가장 먼저 할 생각은?',
    options: [
      '퇴사한다.',
      '여행 계획을 세운다.',
      '집을 산다.',
      '투자 계획부터 세운다.',
      '자산 배분 전략을 고민한다.',
    ],
  ),
  _SurveyQuestion(
    situation: '카페에서 음료를 살 때 당신은?',
    prompt: '',
    options: [
      '가격은 크게 신경 쓰지 않는다.',
      '할인 쿠폰이 있으면 사용한다.',
      '가성비를 고려한다.',
      '아낀 돈을 투자할 수 있다고 생각한다.',
      '소비보다 투자 기회비용이 먼저 떠오른다.',
    ],
  ),
  _SurveyQuestion(
    situation: '당신이 가장 부러운 사람은?',
    prompt: '',
    options: [
      '명품을 자유롭게 사는 사람',
      '좋은 차를 타는 사람',
      '세계 여행을 다니는 사람',
      '배당금으로 생활하는 사람',
      '자산이 스스로 돈을 벌어주는 사람',
    ],
  ),
  _SurveyQuestion(
    situation: '1000만 원을 투자한 지 6개월이 지났습니다.',
    prompt: '받아들일 수 있는 결과는?',
    options: [
      '원금 보장',
      '+5% 또는 -3%',
      '+15% 또는 -10%',
      '+30% 또는 -20%',
      '+60% 또는 -40%',
    ],
  ),
  _SurveyQuestion(
    situation: '당신의 가장 중요한 목표는 무엇인가요?',
    prompt: '',
    options: ['지금 행복하게 사는 것', '여유 있는 생활', '안정적인 노후', '경제적 자유', '큰 부를 이루는 것'],
  ),
];
