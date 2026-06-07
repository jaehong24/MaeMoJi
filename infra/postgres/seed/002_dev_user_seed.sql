-- 로컬 개발 단계에서 포트폴리오 등록 API를 바로 테스트하기 위한 기본 사용자 시드입니다.

insert into users (
    email,
    password_hash,
    nickname,
    status
) values (
    'dev@maemoji.local',
    'LOCAL_DEV_ONLY',
    'MaeMoJi 개발 사용자',
    'ACTIVE'
)
on conflict (email) do nothing;
