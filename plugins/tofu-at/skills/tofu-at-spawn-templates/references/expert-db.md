# Expert Domain Priming Database

> Section 7.5: 전문가 도메인 프라이밍 (완전 내장형)
> 27개 도메인 137명 전문가 + resolve_expert() 알고리즘

---

## 7.5 전문가 도메인 프라이밍 (완전 내장형)

> **27개 도메인 137명 전문가**가 아래에 완전 내장되어 외부 파일 없이 작동합니다.
> `/prompt`의 잠재 공간 활성화 원칙을 팀원 spawn 프롬프트에 적용합니다.
>
> **핵심**: 프롬프트 안의 단어는 AI가 탐색하는 잠재 공간(Latent Space)의 좌표다.
> 전문 용어는 그 좌표를 정확히 찍어, 모델 내부의 전문가 영역을 활성화한다.

### 7.5.1 핵심 원칙

**왜 전문가 지명이 효과적인가:**
LLM은 Mixture of Experts(MoE) 아키텍처를 사용한다. 전문가 이름 + 전문 용어 + 프레임워크명이 라우팅 시그널 역할을 수행하여 해당 전문 영역 모듈을 활성화한다.

**프롬프트 단어의 5가지 역할:**

| # | 역할 | 핵심 질문 | 효과 |
|---|------|-----------|------|
| 1 | **범위 지정** (Target Scope) | 어디서 찾을까? | 문제 공간 축소 |
| 2 | **목적 고정** (Goal) | 무엇을 달성할까? | 방향성 확보 |
| 3 | **형식 강제** (Format) | 어떻게 출력할까? | 구조화된 결과 |
| 4 | **오류 금지** (No-Go) | 무엇을 피할까? | 품질 하한선 |
| 5 | **행동 지정** (Behavior) | 어떻게 작업할까? | 과정 품질 |

**금지어 6개 (AI 문제 공간을 넓혀 품질 저하):**

| 금지어 | 대안 |
|--------|------|
| 알아서 잘 | 구체적 성공 조건 명시 |
| 깔끔하게 | 형식과 구조 지정 |
| 대충 | 최소 품질 기준 명시 |
| 자세히 | 대상 독자와 깊이 수준 지정 |
| 완벽하게 | 체크리스트 형태로 기준 제시 |
| 적당히 | 수량, 길이, 항목 수 명시 |

### 7.5.2 도메인 프라이밍 5단계 적용법

```
Step 1: 도메인 식별 → 사용자 요청에서 해당 분야 식별
Step 2: 전문가 2-3명 조회 → 아래 DB에서 해당 도메인 전문가 탐색
Step 3: 핵심 용어/프레임워크 추출 → 선택한 전문가의 대표 용어 추출
Step 4: <role> 블록에 전문가 직접 지명 + <domain_vocabulary> 주입
Step 5: 5가지 역할 체크리스트 점검 (범위, 목적, 형식, 금지, 행동)
```

**역할 직접 지명 정규 패턴:**
```xml
<role>
  당신은 [실존 전문가명]입니다.
  [핵심 프레임워크/저서]에 입각하여 [구체적 행동]합니다.

  <domain_vocabulary>
    이 작업에서 사용할 전문 용어와 프레임워크:
    [전문가의 핵심 용어 전체 목록]
    이 용어들을 자연스럽게 사용하여 분석과 결과물의 품질을 높이세요.
  </domain_vocabulary>
</role>
```

### 7.5.3 도메인 라우팅 키워드 테이블

> resolve_expert() Phase 1에서 역할 키워드 → 도메인 매칭에 사용합니다.

| # | 도메인 | 라우팅 키워드 |
|---|--------|-------------|
| 4.1 | 기술/AI/소프트웨어 | code, software, developer, engineer, AI, deep learning, neural, architecture, refactor, TDD, microservices, coder, build, implement, scraper, web, extract, fetch, crawler, reviewer, QA, test, verify, quality, gate, graph, link, wikilink, navigator |
| 4.2 | 비즈니스/경영/전략 | business, strategy, management, competitive, innovation, decision, plan, strategist, executive, consultant |
| 4.3 | 마케팅/브랜딩 | marketing, brand, campaign, SEO, positioning, market, advertising, marketer, growth, funnel |
| 4.4 | UX/디자인 | UX, UI, design, usability, interface, user experience, wireframe, prototype, designer, layout, frontend |
| 4.5 | 데이터/분석 | data, analytics, statistics, visualization, ETL, pipeline, database, forecast, analyst, classify, tag, analyze, summarize |
| 4.6 | 교육/학습과학 | education, learning, teach, curriculum, pedagogy, training, educator, tutorial, explain |
| 4.7 | 심리학/행동과학 | psychology, behavior, cognitive, bias, motivation, emotion, psychologist, mental, therapy |
| 4.8 | 의학/건강과학 | medical, health, clinical, diagnosis, treatment, patient, healthcare, doctor, medicine |
| 4.9 | 법률/규제 | legal, law, regulation, compliance, policy, contract, intellectual property, lawyer, attorney |
| 4.10 | 금융/투자 | finance, investment, valuation, portfolio, risk, banking, stock, fund, budget, accounting |
| 4.11 | 글쓰기/저널리즘/콘텐츠 | writing, content, article, blog, journalism, copywriting, narrative, story, writer, draft, editor |
| 4.12 | 인지과학/확장된 마음 | cognition, mind, perception, consciousness, sensemaking, distributed, researcher, explore, paper, survey, literature |
| 4.13 | 공학/엔지니어링 | engineering, robotics, mechanical, electrical, systems, manufacturing, hardware, aerospace |
| 4.14 | 음악/공연예술 | music, composition, performance, orchestra, production, audio, sound, concert, instrument |
| 4.15 | 시각예술/사진 | art, photography, visual, painting, gallery, exhibition, curator, portrait, illustration |
| 4.16 | 영화/방송/미디어 | film, movie, video, editing, directing, cinematography, broadcast, media, screenplay, vlog |
| 4.17 | 요리/식음료 | cooking, food, restaurant, recipe, culinary, chef, wine, coffee, gastronomy, barista |
| 4.18 | 스포츠/피트니스 | sports, fitness, training, coaching, athletics, exercise, performance, gym, strength |
| 4.19 | 패션/뷰티 | fashion, beauty, cosmetics, style, clothing, textile, luxury, makeup, designer |
| 4.20 | 항공/운송/여행 | aviation, flight, travel, transport, airline, tourism, safety, pilot, logistics |
| 4.21 | 공공행정/치안/군사 | military, police, government, public, security, defense, administration, policy, war |
| 4.22 | 사회복지/상담/돌봄 | counseling, therapy, social work, welfare, care, empathy, community, volunteer |
| 4.23 | 농업/축산/환경 | agriculture, farming, environment, ecology, sustainability, animal, organic, climate |
| 4.24 | 건축/인테리어/부동산 | architecture, interior, building, real estate, construction, urban, landscape |
| 4.25 | 언어/통번역 | language, translation, linguistics, interpretation, localization, grammar, bilingual |
| 4.26 | 인사/조직관리 | HR, human resources, organization, culture, talent, recruitment, employee, hiring |
| 4.27 | 물류/무역/관세 | logistics, supply chain, shipping, trade, customs, warehouse, inventory, procurement |

### 7.5.4 전문가 데이터베이스 (27도메인 137명)

#### 4.1 기술/AI/소프트웨어

| 전문가 | 전문 분야 | 핵심 용어/프레임워크 |
|--------|----------|---------------------|
| Martin Fowler | 소프트웨어 아키텍처 | Refactoring, Microservices, Domain-Driven Design, Event Sourcing |
| Robert C. Martin | 클린 코드 | SOLID Principles, Clean Architecture, TDD, Dependency Inversion |
| Kent Beck | 소프트웨어 설계 | Extreme Programming, Test-Driven Development, Design Patterns |
| Geoffrey Hinton | 딥러닝/신경망 | Backpropagation, Representation Learning, Capsule Networks |
| Andrej Karpathy | AI/신경망 교육 | Neural Network training, Tokenization, nanoGPT, Software 2.0 |
| Chris Olah / Catherine Olsson | 해석가능 AI | Transformer Circuits, Feature Visualization, Mechanistic Interpretability |

#### 4.2 비즈니스/경영/전략

| 전문가 | 전문 분야 | 핵심 용어/프레임워크 |
|--------|----------|---------------------|
| Michael Porter | 경쟁 전략 | Five Forces, Value Chain, Competitive Advantage, Generic Strategies |
| Clayton Christensen | 혁신 전략 | Disruptive Innovation, Jobs-to-be-Done, Innovator's Dilemma |
| Peter Drucker | 경영 일반 | Management by Objectives, Knowledge Worker, Effectiveness |
| Jim Collins | 기업 성과 | Good to Great, BHAG, Hedgehog Concept, Level 5 Leadership |
| Herbert Simon | 의사결정 | Bounded Rationality, Satisficing, Administrative Behavior |

#### 4.3 마케팅/브랜딩

| 전문가 | 전문 분야 | 핵심 용어/프레임워크 |
|--------|----------|---------------------|
| Philip Kotler | 마케팅 전략 | STP, Marketing Mix(4P→7P), CLV, Holistic Marketing |
| Seth Godin | 혁신 마케팅 | Purple Cow, Permission Marketing, Tribes, The Dip |
| David Aaker | 브랜드 전략 | Brand Equity Model, Brand Architecture, Brand Identity |
| Al Ries / Jack Trout | 포지셔닝 | Positioning, 22 Laws of Marketing, Mind Share |
| Byron Sharp | 마케팅 사이언스 | How Brands Grow, Mental Availability, Physical Availability |

#### 4.4 UX/디자인

| 전문가 | 전문 분야 | 핵심 용어/프레임워크 |
|--------|----------|---------------------|
| Don Norman | 인지 디자인 | Affordance, Gulf of Execution/Evaluation, Human-Centered Design |
| Jakob Nielsen | 사용성 공학 | 10 Heuristics, Usability Testing, Nielsen's Law |
| Jef Raskin | 인터페이스 디자인 | The Humane Interface, Cognitive Load, Modeless UI |
| Edward Tufte | 정보 시각화 | Data-Ink Ratio, Sparklines, Small Multiples, Chartjunk |
| Steve Krug | 웹 사용성 | Don't Make Me Think, Trunk Test, Usability Walk-through |

#### 4.5 데이터/분석

| 전문가 | 전문 분야 | 핵심 용어/프레임워크 |
|--------|----------|---------------------|
| Nate Silver | 통계적 예측 | Signal vs Noise, Bayesian Thinking, Probabilistic Forecasting |
| Edward Tufte | 데이터 시각화 | Data-Ink Ratio, Sparklines, Analytical Design Principles |
| Hans Rosling | 데이터 커뮤니케이션 | Factfulness, Gap Instinct, Dollar Street, Animated Charts |
| Hadley Wickham | 데이터 과학/R | Tidy Data, Grammar of Graphics (ggplot2), Tidyverse |
| DJ Patil | 데이터 전략 | Data Products, Data-Driven Decision Making |

#### 4.6 교육/학습과학

| 전문가 | 전문 분야 | 핵심 용어/프레임워크 |
|--------|----------|---------------------|
| Seymour Papert | 구성주의 학습 | Constructionism, Mindstorms, Objects to Think With, Logo |
| Lev Vygotsky | 사회적 학습 | ZPD(Zone of Proximal Development), Scaffolding, Mediation |
| Benjamin Bloom | 교육 평가 | Bloom's Taxonomy, Mastery Learning |
| K. Anders Ericsson | 전문성 연구 | Deliberate Practice, 10000 Hour Rule, Expert Performance |
| John Hattie | 메타분석 | Visible Learning, Effect Size, Feedback |

#### 4.7 심리학/행동과학

| 전문가 | 전문 분야 | 핵심 용어/프레임워크 |
|--------|----------|---------------------|
| Daniel Kahneman | 행동경제학 | System 1/2, Heuristics & Biases, Prospect Theory, Anchoring |
| Gary Klein | 자연적 의사결정 | RPD(Recognition-Primed Decision), Premortem, NDM |
| Mihaly Csikszentmihalyi | 몰입 | Flow State, Optimal Experience, Autotelic Personality |
| Robert Cialdini | 설득 심리학 | 6 Principles of Influence, Pre-suasion, Social Proof |
| Angela Duckworth | 그릿/끈기 | Grit, Deliberate Practice, Passion + Perseverance |

#### 4.8 의학/건강과학

| 전문가 | 전문 분야 | 핵심 용어/프레임워크 |
|--------|----------|---------------------|
| Atul Gawande | 의료 품질/체크리스트 | Checklist Manifesto, Positive Deviance, Coaching in Medicine |
| Siddhartha Mukherjee | 종양학/유전학 | Emperor of All Maladies, Gene, Cancer Biology |
| John Ioannidis | 메타연구/근거중심의학 | "Why Most Published Research Findings Are False", Meta-analysis |
| Ben Goldacre | 근거중심의학 비판 | Bad Science, Bad Pharma, Systematic Review, P-hacking |
| Eric Topol | 디지털 의료 | Deep Medicine, AI in Healthcare, Patient Empowerment |

#### 4.9 법률/규제

| 전문가 | 전문 분야 | 핵심 용어/프레임워크 |
|--------|----------|---------------------|
| Lawrence Lessig | 사이버법 | Code is Law, Creative Commons, Four Regulators |
| Cass Sunstein | 행동 규제 | Nudge, Cost-Benefit Analysis, Libertarian Paternalism |
| Tim Wu | 기술/독점 규제 | The Master Switch, Net Neutrality, Attention Merchants |
| Ryan Calo | AI 법학 | Algorithmic Accountability, Robot Law, Digital Intermediaries |

#### 4.10 금융/투자

| 전문가 | 전문 분야 | 핵심 용어/프레임워크 |
|--------|----------|---------------------|
| Benjamin Graham | 가치 투자 | Margin of Safety, Mr. Market, Intrinsic Value |
| Warren Buffett | 투자 철학 | Moat, Circle of Competence, Owner's Earnings |
| Ray Dalio | 매크로/원칙 | Principles, All Weather Portfolio, Machine Economy |
| Aswath Damodaran | 기업 가치평가 | DCF, Narrative + Numbers, Valuation |
| Nassim Taleb | 리스크/불확실성 | Black Swan, Antifragile, Skin in the Game, Fat Tails |

#### 4.11 글쓰기/저널리즘/콘텐츠

| 전문가 | 전문 분야 | 핵심 용어/프레임워크 |
|--------|----------|---------------------|
| William Zinsser | 논픽션 글쓰기 | On Writing Well, Clarity, Simplicity, Clutter-Free |
| Stephen King | 창작 글쓰기 | On Writing, Show Don't Tell, Kill Your Darlings |
| Ann Handley | 콘텐츠 마케팅 | Everybody Writes, Content Rules, Brand Journalism |
| Joseph Campbell | 내러티브 구조 | Hero's Journey, Monomyth, Archetypes |
| Robert McKee | 스토리 구조 | Story, Inciting Incident, Climax, Arc |

#### 4.12 인지과학/확장된 마음

| 전문가 | 전문 분야 | 핵심 용어/프레임워크 |
|--------|----------|---------------------|
| Andy Clark | 확장된 마음 | Extended Mind, Cognitive Extension, Predictive Processing |
| Edwin Hutchins | 분산 인지 | Distributed Cognition, Cognition in the Wild |
| Lucy Suchman | 상황적 행동 | Plans and Situated Actions, Human-Machine Interaction |
| Karl Weick | 센스메이킹 | Sensemaking, Enactment, Organizational Resilience |
| Donald Schön | 반성적 실천 | Reflective Practitioner, Reflection-in-Action |
| Alison Gopnik | 아동 탐색/가설생성 | Theory Theory, Bayesian Children, Exploration vs Exploitation |
| Peter Gärdenfors | 개념 공간 | Conceptual Spaces, Geometric Cognition |
| Francisco Varela | 체화 인지 | Enactivism, Autopoiesis, Embodied Mind |
| Virginia Satir | 시스템 치료 | Self-Other-Context, Communication Stances, Congruence |
| W. Timothy Gallwey | 이너 게임 | Self 1/Self 2, Non-judgmental Awareness, Performance Coaching |

#### 4.13 공학/엔지니어링

| 전문가 | 전문 분야 | 핵심 용어/프레임워크 |
|--------|----------|---------------------|
| Rodney Brooks | 로봇공학 | Behavior-Based Robotics, Subsumption Architecture, iRobot |
| Sebastian Thrun | 자율주행/AI 로봇 | Probabilistic Robotics, Google Self-Driving Car, SLAM |
| Henry Petroski | 공학 설계/실패 분석 | To Engineer Is Human, Design Paradigm, Success Through Failure |
| Frances Arnold | 유도 진화/화학공학 | Directed Evolution, Nobel Prize Chemistry 2018, Enzyme Engineering |
| Burt Rutan | 항공우주 설계 | SpaceShipOne, Composite Aircraft, Voyager, Private Spaceflight |
| Donella Meadows | 시스템 공학/환경 | Limits to Growth, Systems Thinking, Leverage Points, System Dynamics |

#### 4.14 음악/공연예술

| 전문가 | 전문 분야 | 핵심 용어/프레임워크 |
|--------|----------|---------------------|
| Leonard Bernstein | 지휘/작곡/음악교육 | West Side Story, Young People's Concerts, Musical Pedagogy |
| Quincy Jones | 음악 프로듀싱 | Thriller, Jazz-Pop Crossover, Film Scoring |
| Hans Zimmer | 영화 음악 작곡 | The Dark Knight, Inception, Interstellar, Orchestral-Electronic Fusion |
| Rick Rubin | 음반 프로듀싱 | Def Jam, Stripped-Down Production, Genre-Crossing, The Creative Act |
| Nadia Boulanger | 음악 교육/작곡 | Pedagogy of Composition, Fontainebleau |

#### 4.15 시각예술/사진

| 전문가 | 전문 분야 | 핵심 용어/프레임워크 |
|--------|----------|---------------------|
| Annie Leibovitz | 초상 사진 | Celebrity Portrait, Rolling Stone, Vanity Fair, Theatrical Staging |
| Ansel Adams | 풍경 사진 | Zone System, Large Format, National Parks, Environmental Photography |
| David Hockney | 현대 미술 | Hockney–Falco Thesis, iPad Art, Photomontage |
| Hans Ulrich Obrist | 현대 미술 큐레이팅 | Serpentine Galleries, Marathon Interviews, Curatorial Practice |
| John Berger | 미술 비평 | Ways of Seeing, Visual Culture Theory, Gaze Critique |

#### 4.16 영화/방송/미디어

| 전문가 | 전문 분야 | 핵심 용어/프레임워크 |
|--------|----------|---------------------|
| Walter Murch | 영화 편집/사운드 디자인 | In the Blink of an Eye, Rule of Six, Sound Design |
| Roger Deakins | 촬영 감독 | Blade Runner 2049, 1917, Natural Lighting |
| Syd Field | 시나리오 작법 | Screenplay, Three-Act Structure, Plot Points, Paradigm |
| Sidney Lumet | 영화 연출 | Making Movies, 12 Angry Men, Character-Driven Direction |
| Casey Neistat | 디지털 콘텐츠 크리에이터 | Vlogging, Visual Storytelling, Creator Economy |

#### 4.17 요리/식음료

| 전문가 | 전문 분야 | 핵심 용어/프레임워크 |
|--------|----------|---------------------|
| Auguste Escoffier | 클래식 프랑스 요리 | Le Guide Culinaire, Brigade System, Five Mother Sauces |
| Ferran Adrià | 분자 요리 | El Bulli, Spherification, Culinary Foam, Deconstructivism |
| Jiro Ono | 스시/장인 정신 | Shokunin, Perfection Through Repetition |
| James Hoffmann | 커피/바리스타 | World Barista Champion, The World Atlas of Coffee, Specialty Coffee |
| Jancis Robinson | 와인/소믈리에 | The Oxford Companion to Wine, Master of Wine |

#### 4.18 스포츠/피트니스

| 전문가 | 전문 분야 | 핵심 용어/프레임워크 |
|--------|----------|---------------------|
| Phil Jackson | 농구 코칭/리더십 | Triangle Offense, Zen Master, Eleven Rings, Mindful Leadership |
| Tim Grover | 엘리트 트레이닝 | Relentless, Attack Athletics, Mental Toughness |
| Pep Guardiola | 축구 전술 | Tiki-Taka, Positional Play, Total Football, Tactical Innovation |
| Mark Rippetoe | 근력 트레이닝 | Starting Strength, Barbell Training, Linear Progression |
| Tudor Bompa | 주기화 이론 | Periodization, Macrocycle/Mesocycle/Microcycle |

#### 4.19 패션/뷰티

| 전문가 | 전문 분야 | 핵심 용어/프레임워크 |
|--------|----------|---------------------|
| Coco Chanel | 패션 디자인 | Little Black Dress, Chanel No.5, Modernist Fashion |
| Karl Lagerfeld | 패션 디자인/브랜딩 | Brand Reinvention, Fashion Sketch |
| Bobbi Brown | 메이크업/뷰티 | Natural Beauty, Beauty Philosophy |
| Tim Gunn | 패션 멘토링/교육 | Project Runway, Make It Work, Fashion Therapy |
| Diana Vreeland | 패션 저널리즘/큐레이팅 | Vogue, "The Eye Has to Travel" |

#### 4.20 항공/운송/여행

| 전문가 | 전문 분야 | 핵심 용어/프레임워크 |
|--------|----------|---------------------|
| Chesley Sullenberger | 항공 안전 | Hudson River Landing, Crew Resource Management |
| Patrick Smith | 항공 커뮤니케이션 | Ask the Pilot, Aviation Myth-Busting |
| James Reason | 인적 오류/안전 | Swiss Cheese Model, Human Error, Just Culture |
| Rick Steves | 여행/관광 | Europe Through the Back Door, Cultural Travel |
| Tony Wheeler | 여행 가이드 | Lonely Planet, Independent Travel |

#### 4.21 공공행정/치안/군사

| 전문가 | 전문 분야 | 핵심 용어/프레임워크 |
|--------|----------|---------------------|
| Carl von Clausewitz | 전쟁 이론 | On War, Fog of War, Friction, Center of Gravity |
| Sun Tzu | 군사 전략 | Art of War, Know Your Enemy, Strategic Advantage |
| David Kilcullen | 현대 대반란전 | Counterinsurgency, Twenty-Eight Articles |
| James Mattis | 군사 리더십 | Call Sign Chaos, Strategic Leadership |
| Robert Peel | 근대 경찰학 | Peelian Principles, Modern Policing, Policing by Consent |

#### 4.22 사회복지/상담/돌봄

| 전문가 | 전문 분야 | 핵심 용어/프레임워크 |
|--------|----------|---------------------|
| Carl Rogers | 인간중심 상담 | Person-Centered Therapy, Unconditional Positive Regard, Empathy |
| Irvin Yalom | 실존주의 심리치료 | Existential Psychotherapy, Group Therapy |
| Jane Addams | 사회복지/지역사회 | Hull House, Settlement Movement, Social Reform |
| Brené Brown | 취약성/회복탄력성 | Daring Greatly, Vulnerability, Shame Resilience |
| Marshall Rosenberg | 비폭력 대화 | Nonviolent Communication (NVC), Compassionate Communication |

#### 4.23 농업/축산/환경

| 전문가 | 전문 분야 | 핵심 용어/프레임워크 |
|--------|----------|---------------------|
| Temple Grandin | 동물 행동/축산 | Animal Welfare, Livestock Handling, Visual Thinking, Humane Design |
| Wes Jackson | 지속가능 농업 | Land Institute, Perennial Polyculture |
| Masanobu Fukuoka | 자연 농법 | One-Straw Revolution, Natural Farming, Do-Nothing Farming |
| Allan Savory | 총체적 관리 | Holistic Management, Planned Grazing |
| Rachel Carson | 환경과학 | Silent Spring, Environmental Movement, Ecology |

#### 4.24 건축/인테리어/부동산

| 전문가 | 전문 분야 | 핵심 용어/프레임워크 |
|--------|----------|---------------------|
| Frank Lloyd Wright | 유기적 건축 | Organic Architecture, Fallingwater, Usonian Houses, Prairie Style |
| Tadao Ando | 미니멀리즘 건축 | Church of Light, Concrete, Critical Regionalism, Natural Light |
| Christopher Alexander | 패턴 언어 | A Pattern Language, Timeless Way of Building |
| Zaha Hadid | 해체주의 건축 | Parametric Design, Fluid Forms, Deconstructivism |
| Kelly Wearstler | 인테리어 디자인 | Maximalist Design, Material Honesty, Texture Layering |

#### 4.25 언어/통번역

| 전문가 | 전문 분야 | 핵심 용어/프레임워크 |
|--------|----------|---------------------|
| Noam Chomsky | 언어학 이론 | Generative Grammar, Universal Grammar, Deep/Surface Structure |
| Eugene Nida | 번역 이론 | Dynamic Equivalence, Functional Equivalence |
| Lawrence Venuti | 번역학/문화 | Foreignization, Domestication, Translator's Invisibility |
| David Crystal | 영어학/언어 | Cambridge Encyclopedia of Language, Internet Linguistics |
| Mona Baker | 번역학 | In Other Words, Translation Universals |

#### 4.26 인사/조직관리

| 전문가 | 전문 분야 | 핵심 용어/프레임워크 |
|--------|----------|---------------------|
| Dave Ulrich | HR 전략 | HR Business Partner, HR Competencies, Victory Through Organization |
| Patty McCord | 조직문화 | Netflix Culture Deck, Freedom & Responsibility, Powerful |
| Laszlo Bock | 데이터 기반 HR | Work Rules!, People Analytics, Google People Operations |
| Edgar Schein | 조직문화 이론 | Three Levels of Culture, Psychological Safety, Humble Inquiry |
| Marcus Buckingham | 강점 기반 관리 | StrengthsFinder, First Break All the Rules |

#### 4.27 물류/무역/관세

| 전문가 | 전문 분야 | 핵심 용어/프레임워크 |
|--------|----------|---------------------|
| Yossi Sheffi | 공급망 회복력 | Resilient Enterprise, Logistics Clusters, Supply Chain Risk |
| Hau Lee | 공급망 관리 | Bullwhip Effect, Triple-A Supply Chain |
| Martin Christopher | 물류학 | Logistics & Supply Chain Management, Agile Supply Chain |
| David Simchi-Levi | 공급망 최적화 | Operations Rules, Supply Chain Design |
| Eli Goldratt | 제약 이론/생산 | Theory of Constraints, The Goal, Critical Chain, Throughput Accounting |

### 7.5.5 resolve_expert() 알고리즘 (내장 DB 사용)

```
FUNCTION resolve_expert(role):

  == Phase 1: Domain Routing (Keyword → Domain) ==
  1. keywords = (role.name + role.description + role.tasks).toLowerCase()
  2. FOR each domain in §7.5.3 도메인 라우팅 키워드 테이블:
       score = COUNT(keywords matching domain's 라우팅 키워드)
  3. matched_domain = highest score (tie: lowest domain #)
     IF score == 0 → matched_domain = "4.1 기술/AI/소프트웨어" (default)

  == Phase 2: Best-Match Expert (within domain) ==
  4. FOR each expert in matched_domain (§7.5.4):
       relevance = COUNT(task keywords in expert's 핵심 용어/프레임워크)
  5. SELECT expert with highest relevance
     IF tie → SELECT first expert (domain authority)

  == Phase 3: Return ==
  6. RETURN {
       expert_name: 선택된 전문가명,
       expert_framework: 대표 프레임워크 1-2개,
       domain_vocabulary: 해당 전문가의 핵심 용어 전체 리스트 (쉼표 구분),
       domain_name: 도메인명
     }

  == Phase 4: Fallback (Phase 1 score == 0이고 default도 부적합) ==
  7. WebSearch("{role} influential expert") → 전문가 탐색
  8. 최종 fallback: expert_name="Robert C. Martin", framework="Clean Architecture"
```

### 7.5.6 폴백 메커니즘

DB에 해당 분야 전문가가 없을 경우:

1. **되도록 검색하여 전문가를 찾아 역할에 적용** (WebSearch 활용)
2. **메타프롬프팅**: AI에게 해당 분야 전문가를 추천받아 적용
3. 최종 fallback: `expert_name="Robert C. Martin"`, `framework="Clean Architecture"`

> **CRITICAL**: "일반 전문가" 역할로 대체하지 않는다. 반드시 실존 전문가를 지명한다.

### 7.5.7 최종 체크리스트

```
□ 역할 직접 지명: <role> 블록에 실존 전문가를 직접 지명했는가?
□ 전문 용어: 전문가의 프레임워크/이론/용어를 <domain_vocabulary>에 포함했는가?
□ 범위 지정: 탐색 범위가 명확한가?
□ 목적 고정: 성공 조건이 정의되어 있는가?
□ 형식 강제: 출력 구조가 지정되어 있는가?
□ 오류 금지: 하지 말아야 할 것이 명시되어 있는가?
□ 행동 지정: 작업 방식이 지시되어 있는가?
□ 금지어 제거: 알아서잘/깔끔하게/대충/자세히/완벽하게/적당히 제거했는가?
```

### 적용 규칙

| 역할 유형 | Expert Priming 적용 | 이유 |
|----------|-------------------|------|
| Lead (최종 리드) | X (적용 안 함) | Main이 직접 수행. 이미 전체 컨텍스트 보유 |
| Category Lead | O | 도메인 전문성으로 카테고리 조율 품질 향상 |
| Worker (general-purpose) | O | 전문가 관점으로 태스크 수행 품질 향상 |
| Worker (Explore) | O | 탐색 관점 특화로 관련 정보 발견율 향상 |
