# Copilot instructions for AffinityVoice

## Architecture and data flow
- Flutter app with a single `MaterialApp` router defined in `lib/main.dart` (named routes; conversation detail reads the conversation ID from route arguments).
- UI lives under `lib/screens/` and reads/writes data through a singleton repository (`ConversationRepository.instance`) in `lib/repositories/conversation_repository.dart`.
- State is in-memory only; the repository is the single source of truth for conversations and auto-read sessions.
- Models in `lib/models/` (`Conversation`, `AutoReadSession`) are immutable; updates must go through `copyWith(...)` and repository replace logic.

## Project-specific patterns
- Screens are `StatefulWidget`s that call repository methods and then `setState()` to refresh (see `ConversationListScreen` and `ConversationDetailScreen`).
- Auto-Read session logic lives in the repository; expiration is enforced in `getActiveSessions()` by pruning expired entries.
- Voice assignment updates both the conversation and any active auto-read session for that conversation (`assignVoice(...)`).

## Integration points and dependencies
- `ConversationDetailScreen` and `AutoReadSessionsScreen` reference a `VoicePresets` lookup (`VoicePresets.all` / `VoicePresets.byId`), expected under `lib/models/assigned_voice.dart`.

## Examples to follow
- Updating conversation state: use `Conversation.copyWith(...)` and `_replaceConversation(...)` in the repository.
- Navigating to details: use `Navigator.pushNamed(context, '/conversation-detail', arguments: convo.id)` and refresh on return.
