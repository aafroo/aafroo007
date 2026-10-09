# CLAUDE.md

Projekt: strony internetowe i aplikacje webowe. Odpowiadaj użytkownikowi po polsku.

## Narzędzia

| Narzędzie | Źródło | Jak dostępne |
|---|---|---|
| superpowers | `obra/superpowers` przez `superpowers@claude-plugins-official` | wtyczka, skille `superpowers:*` |
| frontend-design | `frontend-design@claude-plugins-official` (Anthropic) | wtyczka, skill `frontend-design:frontend-design` |
| gstack | `garrytan/gstack` w `~/.claude/skills/gstack` | skille `/review`, `/qa`, `/ship`, ... |

`.claude/settings.json` włącza obie wtyczki, a `.claude/hooks/session-start.sh`
instaluje brakujące narzędzia na starcie każdej sesji w chmurze. Wtyczki
zainstalowane przez hook są widoczne jako skille dopiero od następnej sesji;
do tego czasu czytaj ich `SKILL.md` z `~/.claude/plugins/cache/claude-plugins-official/`.

## Proces pracy

ANALIZA → PLAN → PROJEKT → IMPLEMENTACJA → CODE REVIEW → TESTY → POPRAWKI → PUBLIKACJA

Każdy etap ma jedno narzędzie główne. Narzędzia dodatkowe uruchamiaj tylko wtedy,
gdy zadanie ich wymaga. Nie powtarzaj tego samego kroku dwoma narzędziami
(np. dwóch code review jednego diffu).

| Etap | Narzędzie główne | Dodatkowo, gdy potrzeba | Wynik etapu |
|---|---|---|---|
| 1. ANALIZA | `superpowers:brainstorming` | `/office-hours` (nowy produkt), `/spec` (mglisty zakres), `/investigate` (istniejący kod) | uzgodnione wymagania i zakres |
| 2. PLAN | `superpowers:writing-plans` | `/plan-eng-review`, `/plan-design-review` dla UI, `/autoplan` | zapisany plan z krokami i testami |
| 3. PROJEKT | `frontend-design:frontend-design` | `/design-consultation` (system projektowy), `/design-shotgun` (warianty) | kierunek wizualny, tokeny, makiety/komponenty |
| 4. IMPLEMENTACJA | `superpowers:subagent-driven-development` lub `superpowers:executing-plans` | `superpowers:test-driven-development`, `superpowers:using-git-worktrees` | kod z testami, commity na gałęzi |
| 5. CODE REVIEW | `/review` (gstack) | `superpowers:receiving-code-review` do obsługi uwag, `/cso` (bezpieczeństwo) | lista uwag do poprawy |
| 6. TESTY | testy projektu + `/qa-only` (przeglądarka, raport) | `/design-review` (wizualnie), `/benchmark` (wydajność) | raport błędów z dowodami |
| 7. POPRAWKI | `/qa` (naprawa i ponowny test) | `superpowers:systematic-debugging`, `/investigate` | zielone testy, zamknięte uwagi z review |
| 8. PUBLIKACJA | `/ship` (testy, review, wersja, CHANGELOG, PR) | `/document-release`, `/setup-deploy` → `/land-and-deploy` → `/canary` | PR / wdrożenie |

Zasady:
- Przed ogłoszeniem, że coś jest gotowe, użyj `superpowers:verification-before-completion`:
  uruchom testy i pokaż ich wynik. Bez dowodu nie ma „zrobione”.
- Etap 5 i 6 zaczynaj dopiero, gdy implementacja się kompiluje i przechodzą testy jednostkowe.
- Pętla 5 → 7 trwa, dopóki `/review` i `/qa-only` nie zwracają nowych problemów.
- Małe zmiany (literówka, jedna linia) nie wymagają pełnego procesu.

## gstack (recommended)

This project uses [gstack](https://github.com/garrytan/gstack) for AI-assisted workflows.
Install it for the best experience:

```bash
git clone --depth 1 https://github.com/garrytan/gstack.git ~/.claude/skills/gstack
cd ~/.claude/skills/gstack && ./setup --team
```

Skills like /qa, /ship, /review, /investigate, and /browse become available after install.
Use /browse for all web browsing (Aside first, the bundled gstack browser as fallback). Use ~/.claude/skills/gstack/... for gstack file paths.
