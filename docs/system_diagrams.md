# Haber Merkezi - Sistem Diyagramları

## 🏗️ Clean Architecture Diyagramı

```mermaid
graph TD
    A[Presentation Layer] --> B[Domain Layer]
    B --> C[Data Layer]
    
    A1[Pages/Widgets] --> A
    A2[Providers/Riverpod] --> A
    A3[Themes] --> A
    
    B1[Entities] --> B
    B2[Use Cases] --> B
    B3[Repository Interface] --> B
    
    C1[Models] --> C
    C2[Data Sources] --> C
    C3[Repository Implementation] --> C
    
    D[RSS API] --> C2
    E[Local Storage/Hive] --> C2
```

## 📱 Uygulama Akış Diyagramı

```mermaid
flowchart TD
    Start([App Start]) --> Splash[Splash Screen]
    Splash --> CheckConnection{Internet Connection?}
    
    CheckConnection -->|Yes| FetchRSS[Fetch RSS Feeds]
    CheckConnection -->|No| LoadLocal[Load Cached Articles]
    
    FetchRSS --> ParseXML[Parse XML Data]
    ParseXML --> SaveLocal[Save to Local Storage]
    SaveLocal --> ShowArticles[Display Articles]
    
    LoadLocal --> ShowArticles
    ShowArticles --> UserAction{User Action}
    
    UserAction -->|Select Category| FilterCategory[Filter by Category]
    UserAction -->|Pull to Refresh| RefreshData[Refresh RSS Data]
    UserAction -->|Tap Article| ShowDetail[Article Detail]
    UserAction -->|Toggle Theme| ChangeTheme[Switch Theme Mode]
    
    FilterCategory --> ShowArticles
    RefreshData --> FetchRSS
    ShowDetail --> OpenBrowser[Open Source in Browser]
    ChangeTheme --> ShowArticles
```

## 🔄 State Management Akışı (Riverpod)

```mermaid
sequenceDiagram
    participant UI as UI Widget
    participant Provider as News Provider
    participant UseCase as Use Case
    participant Repo as Repository
    participant API as RSS API
    participant Cache as Local Storage

    UI->>Provider: Request articles
    Provider->>UseCase: Execute get articles
    UseCase->>Repo: Fetch articles
    
    alt Online Mode
        Repo->>API: HTTP request
        API-->>Repo: RSS XML data
        Repo->>Cache: Save articles
    else Offline Mode
        Repo->>Cache: Load cached articles
    end
    
    Cache-->>Repo: Articles data
    Repo-->>UseCase: Articles list
    UseCase-->>Provider: Update state
    Provider-->>UI: Notify state change
    UI->>UI: Rebuild with new data
```

## 🗄️ Data Flow Diyagramı

```mermaid
graph LR
    A[RSS Feeds] --> B[HTTP Client - Dio]
    B --> C[XML Parser]
    C --> D[Article Models]
    D --> E[Repository]
    E --> F[Local Storage - Hive]
    E --> G[Riverpod Providers]
    G --> H[UI Components]
    
    F --> E
    H --> I[User Interactions]
    I --> J[Pull to Refresh]
    I --> K[Category Filter]
    I --> L[Article Detail]
    
    J --> A
    K --> G
    L --> M[URL Launcher]
```

## 🎯 Use Case Diyagramı

```mermaid
graph TD
    User([User]) --> UC1[View Articles by Category]
    User --> UC2[Refresh Articles]
    User --> UC3[View Article Details]
    User --> UC4[Share Article]
    User --> UC5[Toggle Dark Mode]
    User --> UC6[Search Articles]
    
    UC1 --> R1[News Repository]
    UC2 --> R1
    UC3 --> R1
    UC4 --> Share[Share Service]
    UC5 --> Theme[Theme Provider]
    UC6 --> R1
    
    R1 --> API[RSS API Service]
    R1 --> Local[Local Storage Service]
```

## 📊 Component Hierarchy

```mermaid
graph TD
    App[MyApp] --> Home[HomePage]
    App --> Detail[ArticleDetailPage]
    App --> Settings[SettingsPage]
    
    Home --> AppBar[Custom AppBar]
    Home --> CategoryTabs[Category Tabs]
    Home --> NewsList[News List View]
    Home --> BottomNav[Bottom Navigation]
    
    NewsList --> ArticleCard1[Article Card]
    NewsList --> ArticleCard2[Article Card]
    NewsList --> LoadMore[Load More Button]
    
    ArticleCard1 --> CachedImage[Cached Network Image]
    ArticleCard1 --> Title[Article Title]
    ArticleCard1 --> Date[Publish Date]
    ArticleCard1 --> Summary[Article Summary]
    
    Detail --> DetailHeader[Detail Header]
    Detail --> DetailContent[Detail Content]
    Detail --> ShareButton[Share Button]
    Detail --> SourceButton[View Source Button]
```

## 🔧 Error Handling Flow

```mermaid
flowchart TD
    Start([API Call]) --> TryFetch{Try Fetch RSS}
    TryFetch -->|Success| ParseData[Parse XML Data]
    TryFetch -->|Network Error| CheckCache{Cache Available?}
    TryFetch -->|Server Error| ShowError[Show Error Message]
    
    CheckCache -->|Yes| LoadCache[Load Cached Data]
    CheckCache -->|No| ShowOffline[Show Offline Message]
    
    ParseData --> ValidateData{Data Valid?}
    ValidateData -->|Yes| UpdateUI[Update UI]
    ValidateData -->|No| ShowError
    
    LoadCache --> UpdateUI
    ShowError --> RetryButton[Show Retry Button]
    ShowOffline --> RetryButton
    
    RetryButton --> TryFetch
    UpdateUI --> End([Complete])