# Fieldnotes — LLM Context

**Эталонное Rails-приложение в стиле DHH и Basecamp.**
Это референсная реализация Rails Way — так, как строят продукты в 37signals.
Каждое решение здесь должно быть ответом на вопрос: «А как бы это сделал DHH?»

---

## The Rails Doctrine (DHH)

### 1. The Majestic Monolith
Одно приложение. Один деплой. Один репозиторий. Никаких микросервисов, никаких API-first,
никаких отдельных фронтенд-приложений. HTML рендерится на сервере и отправляется в браузер.
Если нужна интерактивность — Turbo + Stimulus, не SPA.

### 2. Convention over Configuration
Если Rails предлагает способ — используй его. Не изобретай свой routing, свой ORM, свою
структуру папок. Имена файлов, классов, таблиц — всё по конвенции. `EssaysController` →
`app/controllers/essays_controller.rb` → `app/views/essays/`. Никаких сюрпризов.

### 3. The Menu Is Omakase
Используй то, что Rails положил на тарелку: Active Record, Action Text, Active Storage,
Active Job, Turbo, Stimulus, Solid Queue, Solid Cache, Solid Cable. Не тащи гем для того,
что фреймворк уже делает. Каждый гем — это зависимость, которая сломается.

### 4. No One Paradigm
Callbacks — это нормально. Concerns — это нормально. Helpers — это нормально.
Не нужно выбирать между ООП и функциональным стилем. Rails — прагматичный фреймворк.
Используй тот инструмент, который делает код короче и понятнее.

### 5. Exalt Beautiful Code
Код должен читаться как проза. Если нужен комментарий чтобы объяснить что делает код —
перепиши код. Имена переменных, методов, классов должны рассказывать историю.
Лучший код — тот, которого нет. Второй лучший — самый короткий, который решает задачу.

### 6. Provide Sharp Knives
Не оборачивай всё в safe-обёртки. `before_destroy` callback может удалить связанные данные —
и это нормально. Доверяй разработчику. Не добавляй guard clauses для невозможных состояний.

### 7. Value Integrated Systems
Полный стек от базы до браузера в одном приложении. Active Storage вместо S3-микросервиса.
Action Text вместо headless CMS. Action Mailer вместо email-сервиса. Solid Queue вместо
Sidekiq + Redis. SQLite вместо PostgreSQL + connection pooling.

### 8. Progress over Stability
Используй новейшие возможности Ruby 4.0 (`it` block parameter, PRISM parser) и Rails 8.1.
Не держись за старые паттерны из совместимости. Код пишется для текущей версии фреймворка.

### 9. Push Up a Big Tent
ERB — потому что любой Rails-разработчик его знает. Minitest — потому что он в stdlib.
Fixtures — потому что они быстрые и декларативные. Без экзотики, без порога входа.

---

## Architecture Principles (Basecamp Style)

### Controllers
- **Максимум 7 actions:** index, show, new, create, edit, update, destroy.
- Нужен дополнительный action? **Создай новый контроллер.** `Essays::PublishesController#create`
  вместо `EssaysController#publish`.
- **Skinny controllers.** Контроллер делает три вещи: принимает params, вызывает модель,
  рендерит ответ. Бизнес-логика — в модели.
- `before_action` для аутентификации и загрузки ресурсов. Не для бизнес-логики.
- Strong params — единственный способ фильтрации входных данных. Никаких form objects.

### Models
- **Fat models** — но не ожиревшие. Модель знает свои правила, свои scopes, свои callbacks.
- Если модель > 200 строк — выноси связанное поведение в **concerns** (`Sluggable`, `Taggable`).
- **Scopes** вместо query objects. `Essay.published` вместо `PublishedEssaysQuery.call`.
- **Callbacks** — это Rails Way. `before_save`, `after_create_commit` — используй их.
  Не борись с фреймворком.
- **Нет service objects** для простых операций. Метод модели или callback достаточно.
  Service object — только когда операция затрагивает несколько несвязанных моделей.
- **Нет presenter/decorator.** Helpers + модель. `essay.reading_time` в модели,
  `badge(status)` в helper.

### Views (ERB)
- **ERB** — единственный шаблонизатор. Никаких Phlex, ViewComponent, Slim, Haml.
- Partials для переиспользования: `_form.html.erb`, `_card.html.erb`.
- `<%# locals: (var:) %>` — строгая декларация параметров partial.
- Helpers для HTML-генерации: `admin_card`, `badge`, `picture_tag`.
- **Никакой логики в views** — максимум `if/each`. Сложная логика → helper или модель.
- Controllers передают `@ivars`. Views читают их. Никаких props, никаких initializers.

### JavaScript (Stimulus + Turbo)
- **Turbo Drive** — бесплатный SPA-эффект без единой строки JS.
- **Turbo Frames** — частичное обновление страницы без полной перезагрузки.
- **Turbo Streams** — real-time обновления через WebSocket (Solid Cable).
- **Stimulus** — минимальный JS для поведения, которое не покрывает Turbo.
  Один контроллер = одно поведение. >50 строк → пересмотри дизайн.
- **Importmaps** — никакого webpack, esbuild, vite. Нет build step для JS.
- **Нет TypeScript.** Vanilla JS. Stimulus-контроллеры настолько маленькие, что типы не нужны.

### CSS (Vanilla, как в Writebook)
- **Рукописный CSS без фреймворков** — ни Tailwind, ни Bootstrap, ни CSS-in-JS. Нет build step.
- Один файл на компонент в `app/assets/stylesheets/`: `colors.css` (токены), `base.css`,
  `buttons.css`, `cards.css`, `admin.css`… Лейауты подключают всё разом (`all_stylesheets`).
- **Дизайн-токены — CSS custom properties** (`--color-accent`, `--font-sans`). Админка —
  та же палитра классов на светлых токенах через `body.admin-theme`.
- **Компонентные классы BEM-стиля** (`card__title`, `nav-link--active`) с параметрами через
  custom properties (`--btn-background`) — как writebook `buttons.css`.
- **Маленький набор утилит** (`flex`, `gap`, `txt-subtle`, `margin-block`) — по образцу
  writebook `utilities.css`. Новую утилиту добавляй только если она нужна в 3+ местах.
- Modern CSS: nesting, logical properties (`inline-size`, `margin-block`), `color-mix()`.
- Никаких inline `style=""`.
- Dark theme, orange accent (`#E8722A`).

### Testing (Basecamp Style)
- **Minitest** — в stdlib, быстрый, простой. Не RSpec.
- **Fixtures** — декларативные, быстрые, загружаются один раз. Не FactoryBot.
- **Нет моков БД.** Тесты работают с реальной базой, реальными запросами.
- **Unit-тесты ключевых механик** — модели, concerns, jobs, controllers.
  System-тесты (Capybara/браузер) сознательно не используем.
- **Тестируй поведение, не реализацию.** Одна хорошая проверка лучше десяти тривиальных.
- `bin/ci` запускает всё.

### Background Jobs
- **Solid Queue** — job queue в SQLite, не Redis. Часть Rails 8.
- Jobs для тяжёлых операций: обработка изображений, извлечение EXIF, отправка email.
- `after_create_commit` → job. Не делай тяжёлое в request cycle.

### Deployment
- **Kamal 2** — Docker-деплой на VPS. Не Heroku, не Kubernetes.
- **SQLite** в production — один файл, нет connection pool, нет отдельного сервера БД.
- **Thruster** — HTTP caching и compression перед Puma.

### Security
- `before_action :require_authentication` — Rails built-in auth. Не Devise, не Pundit.
- Strong params — единственный guard на входные данные.
- **Нет shell injection** — array-form `IO.popen` или `system`, никогда backtick interpolation.
- CSRF protection — Rails default. CSP — via meta tag.

---

## Writebook & Fizzy Patterns (эталонные идиомы 37signals)

Конкретные идиомы из исходников `basecamp/writebook` и `basecamp/fizzy`.
Когда пишешь код в этом репозитории — используй именно эти формы.

### Models

**Statuses — всегда string-enum через `index_by(&:itself)`.** Никаких `STATUSES = %w[...]`
констант с ручными предикатами (writebook `Leaf`, fizzy `Card::Statuses`):

```ruby
enum :status, %w[ draft published ].index_by(&:itself), default: :draft
```

Enum бесплатно даёт `essay.published?`, `essay.published!`, `Essay.published`.

**Модель читается как оглавление.** Первая строка — `include` со списком concerns,
затем ассоциации, callbacks, scopes, публичные методы, `private` (fizzy `Card`):

```ruby
class Essay < ApplicationRecord
  include Publishable, Sluggable

  has_rich_text :content
  has_one_attached :cover, dependent: :purge_later
  ...
end
```

**Concerns двух видов.** Кросс-модельные — в `app/models/concerns/` (`Sluggable`).
Специфичные для одной модели — в её подпапке: `app/models/essay/publishable.rb` →
`module Essay::Publishable` (fizzy: `Card::Statuses`, `Column::Positioned`;
writebook: `Book::Sluggable`). Concern — это глава модели, а не способ шаринга кода.

**Действие — метод модели с транзакцией, не код в контроллере** (fizzy `Card#publish`,
writebook `Book#press`):

```ruby
def publish
  transaction do
    self.published_at ||= Time.current
    published!
  end
end
```

**Позиционирование — concern с `before_create`, никогда в контроллере или view**
(fizzy `Column::Positioned`):

```ruby
included do
  scope :ordered, -> { order(:position) }
  before_create :set_position
end

private
  def set_position
    self.position = (field_series.field_items.maximum(:position) || 0) + 1
  end
```

**Scopes: фильтр и сортировка — раздельно.** `Essay.published` не должен содержать
`order`; сортировка — отдельным scope (`ordered`, `chronologically`,
`reverse_chronologically` — имена из fizzy). Eager loading — именованным scope
`preloaded` / `with_covers`, не `includes` в контроллере.

**`to_param` переопределяется в модели** — вызывающий код передаёт запись, не slug:

```ruby
def to_param = slug        # затем везде: link_to essay.title, essay
```

**Однострочные callbacks — лямбдой, с `if:`** (fizzy):

```ruby
after_save -> { field_series.touch }, if: :published?
```

**Ассоциации:** `default: -> { Current.user }` у `belongs_to`;
`dependent: :purge_later` у attachments; `dependent: :delete_all` там,
где callbacks не нужны.

### Controllers

**Глагол = вложенный ресурс-контроллер** (writebook `Books::PublicationsController`,
fizzy `Cards::PinsController`). Файл — в подпапке ресурса:
`app/controllers/admin/essays/publications_controller.rb`.

**`params.expect`, не `params.require(...).permit`** (fizzy, Rails 8.1):

```ruby
def essay_params
  params.expect(essay: [ :title, :excerpt, :status, :content, :cover ])
end
```

**Bang-методы в контроллерах:** `@essay.update!`, `create!`, `destroy!`,
`find_by!`. Ошибка — это 404/422 от Rails, не ветка `if`.

**`before_action` — только `set_*`, `ensure_*`, `redirect_if_*`** (имена из fizzy).
Общий scoping — controller concern (`include BookScoped`).

**HTTP-кеширование публичных страниц:** `fresh_when` с составным etag, если view
рендерит несколько коллекций (fizzy `my/menus_controller.rb`):

```ruby
fresh_when etag: [ @essays, @series ]
```

`expires_in ..., public: true` для sitemap/фидов. `rate_limit` — только на
`create` auth-эндпоинтов (sessions, passwords), никогда на публичные GET.

### Views

**Partial называется именем модели и кешируется** (writebook `books/_book.html.erb`):

```erb
<% cache essay do %>
  ...
<% end %>
```

Рендер — только collection-формой: `render partial: "essays/card", collection: @essays, as: :essay`.

**`dom_id` для всех id в разметке:** `id="<%= dom_id(field_item) %>"`,
`turbo_frame_tag dom_id(series, :cover)`. Никаких рукописных `id="item-42"`.

**Turbo Streams для мутаций списков в админке** (writebook `leafables/create.turbo_stream.erb`):

```erb
<%# create.turbo_stream.erb %>
<%= turbo_stream.append :field_items, partial: "admin/field_items/item", locals: { item: @item } %>

<%# destroy.turbo_stream.erb %>
<%= turbo_stream.remove @item %>
```

**Turbo Frame с `src:` для ленивых островков** (writebook bookmark):
`turbo_frame_tag dom_id(book, :bookmark), src: book_bookmark_path(book)`.

**Helper строит целый tag и пробрасывает `**, &`** (writebook `leaf_item_tag`,
fizzy `icon_tag`). Условные классы — только `class_names`:

```ruby
def nav_link(label, path, controller:)
  active = controller_path.end_with?(controller)
  link_to label, path,
    class: class_names("nav-link", "nav-link--active": active),
    aria: { current: ("page" if active) }
end
```

**Обёртки над `form_with` — в `FormsHelper`** (writebook `auto_submit_form_with`):
повторяющийся `data: { controller: ... }` у форм прячется в helper, не копируется.

**Строгие `<%# locals: (...) %>`** — в каждом partial с параметрами
(наше правило строже writebook — сохраняем).

### Stimulus

Эталон — writebook `upload_preview_controller.js` (20 строк):

```js
export default class extends Controller {
  static values = { defaultImage: String }
  static targets = [ "image", "input", "button" ]

  previewImage() {
    const file = this.inputTarget.files[0]
    if (file) {
      this.imageTarget.src = URL.createObjectURL(file)
      this.imageTarget.onload = () => { URL.revokeObjectURL(this.imageTarget.src) }
    }
  }
}
```

- Имя описывает поведение: `auto_save`, `copy_to_clipboard`, `upload_preview`,
  `element_removal` — не место применения.
- Только `targets`/`values`/`classes` API. **Никогда `document.getElementById`** —
  контроллер не знает о DOM за пределами своего элемента.
- `URL.createObjectURL` всегда парный `revokeObjectURL`.
- Средний контроллер writebook — ~25 строк. Больше 50 — пересмотри дизайн.

### Jobs

- В job передаётся **запись, не id** — GlobalID сериализует сам:
  `ExtractExifJob.perform_later(field_item)`.
- В `ApplicationJob`: `discard_on ActiveJob::DeserializationError` —
  удалённая запись не должна ронять очередь.
- Регулярная чистка данных — recurring-задачи в `config/recurring.yml`
  (fizzy: шесть cleanup-записей — prune старых событий, джоб, уведомлений).

### Форматирование (rubocop-rails-omakase, как в обоих репо)

- Пробелы внутри скобок литералов: `%w[ draft published ]`, `[ :title, :cover ]`.
- Методы под `private` — с отступом в один уровень.
- Ruby 4.0 / 3.4: `it` в блоках (`leaves.map { it.leafable.markable }` — writebook),
  endless methods для однострочников (`def to_param = slug`).
- Выравнивание однотипных scope по столбцам (fizzy `Card`) — допустимо и приветствуется.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Ruby | 4.0.1 (PRISM parser, YJIT in production) |
| Rails | 8.1.3 |
| Database | SQLite (`sqlite3` gem, WAL — Rails 8.1 defaults) |
| Jobs / Cache / WS | Solid Queue · Solid Cache · Solid Cable |
| Assets | Propshaft · Importmaps · Stimulus |
| Views | **ERB** templates + partials |
| Styling | **Vanilla CSS** (custom properties + BEM-компоненты, стиль writebook) |
| Rich text | Action Text + **Lexxy** `0.9.0.beta` — do NOT use Trix |
| Images | Active Storage + libvips → AVIF |
| Auth | Rails built-in authentication generator |
| Deploy | Kamal 2 |

---

## Hard Rules (Запреты)

- **No Phlex, no ViewComponent, no Slim, no Haml** — only ERB.
- **No Alpine, no HTMX, no React, no Vue** — only Stimulus + Turbo.
- **No RSpec, no FactoryBot** — only Minitest + fixtures.
- **No Devise, no Pundit** — only Rails built-in auth.
- **No ActiveAdmin** — admin на ERB руками.
- **No service objects** где хватит метода модели.
- **No form objects** где хватит strong params.
- **No query objects** где хватит scope.
- **No presenter/decorator** где хватит helper.
- **No Tailwind, no Bootstrap, no CSS-frameworks** — рукописный vanilla CSS.
- **No inline styles** — компонентный класс или утилита.
- **No Redis** — Solid Queue / Cache / Cable.
- **No webpack/esbuild/vite** — Importmaps.
- **No TypeScript** — vanilla JS.
- **No microservices** — majestic monolith.

---

## Data Models

```ruby
# CORE
essays:       title, slug, excerpt, status(draft/published), published_at,
              latitude, longitude, location_name
              has_rich_text :content
              has_one_attached :cover

now_entries:  body(rich text), published_at, location

# OPTIONAL
builds:       title, slug, description, url, icon_emoji,
              status(active/paused/completed/archived), kind(business/oss/media/community/other),
              position, started_on, finished_on
              has_one_attached :cover

books:        title, author, isbn, cover_url, year_read, rating(1-5),
              key_idea(text), status(reading/completed/abandoned)

field_series: title, slug, description, kind(photo/video/mixed),
              location, taken_on, latitude, longitude
              has_one_attached :cover

field_items:  field_series_id, kind(photo/video), caption, position, youtube_url,
              camera_make, camera_model, lens, focal_length, aperture,
              shutter_speed, iso, taken_at, gps_latitude, gps_longitude
              has_one_attached :photo

# SYSTEM
tags/taggings: polymorphic (tag_id, taggable_id, taggable_type)
page_views:    event(string), payload(json), created_at
```

---

## Routes

```ruby
root "public/feed#index"

scope module: :public do
  resources :essays,   only: [:index, :show], param: :slug
  resources :builds,   only: [:index]
  resources :books,    only: [:index, :show]
  resources :field,    only: [:index, :show], param: :slug
  get "/now",     to: "now#show"
  get "/feed",    to: "feed#index"
  get "/contact", to: "pages#contact"
  get "/about",   to: "pages#about"
  get "/uses",    to: "pages#uses"
end

namespace :admin do
  root "essays#index"
  resources :essays, :builds, :books
  resources :field do
    resources :field_items, only: [:create, :destroy, :update]
  end
  resource :quick, only: [:new, :create]
  resource :now, only: [:edit, :update]
end
```

---

## Coding Conventions

- **Ruby 4.0:** `it` block parameter, PRISM parser, endless methods где уместно.
- **Slugs:** `/essays/rails-sqlite-production-2026` not `/essays/1234`.
- **Never inline image variants** — warm via `ImageVariantJob`.
- **Videos:** YouTube facade (`youtube-nocookie.com`) — no local storage.
- **Без комментариев** в коде. Комментарий — только если WHY неочевиден.
- **Без мёртвого кода.** Нет неиспользуемых методов, нет закомментированного кода,
  нет defensive checks для невозможных состояний.

---

## Docs

| Topic | File |
|---|---|
| Architecture & philosophy | `docs/architecture.md` |
| Local setup | `docs/getting-started.md` |
| Deployment | `docs/deployment.md` |
| Design tokens | `docs/design.md` |
| SEO, OG, RSS | `docs/seo.md` |
| Image pipeline | `docs/images.md` |
| Rails 8 features | `docs/rails8-features.md` |
