/* ================================================================
   Akdeniz Kebap – Renderer
   Baut die Speisekarte aus content/menu.json (per CMS bearbeitbar). Kein Framework.
   <body data-page="seite1"> oder "seite2" steuert, was gebaut wird.
   ================================================================ */
(function () {
  "use strict";
  var page = document.body.dataset.page;

  /* ---------- kleine Helfer ---------- */
  function el(tag, cls, txt) {
    var n = document.createElement(tag);
    if (cls) n.className = cls;
    if (txt != null) n.textContent = txt;
    return n;
  }
  function lines(parent, str, cls) {
    str.split("\n").forEach(function (l, i) {
      if (i) parent.appendChild(document.createElement("br"));
      var s = el("span", cls); s.textContent = l;
      parent.appendChild(s);
    });
  }

  var ARROW = '<svg class="note-arrow" viewBox="0 0 120 90" aria-hidden="true">' +
    '<path d="M6 10 C 40 4, 84 12, 104 44" fill="none" stroke="currentColor" ' +
    'stroke-width="7" stroke-linecap="round"/>' +
    '<path d="M104 44 L 86 40 M104 44 L 96 24" fill="none" stroke="currentColor" ' +
    'stroke-width="7" stroke-linecap="round"/></svg>';

  /* Paint-Asset (echtes Bild, img/paint-brush.png) statt generierter Grafik.
     object-fit:contain im CSS erhält das Seitenverhältnis, Größe/Rotation/Position
     je Produkt kommt aus den .card:nth-child(...)-Regeln im CSS. */
  var SWASH = '<img class="swash" src="img/paint-brush.png" alt="" aria-hidden="true">';

  var DECO = '<span class="deco deco-leaves" aria-hidden="true">' +
    '<svg viewBox="0 0 200 200">' +
    '<g fill="none" stroke="#5c8b3c" stroke-width="4" stroke-linecap="round">' +
    '<path d="M150 6C120 40 108 92 120 150"/><path d="M150 34C170 40 184 30 190 14"/>' +
    '<path d="M138 66C160 74 178 66 188 48"/><path d="M128 100C150 110 170 104 182 86"/>' +
    '<path d="M122 134C142 146 162 142 176 124"/></g>' +
    '<g fill="#6ea043">' +
    '<path d="M150 30c14-14 30-16 44-10-6 14-20 24-38 22-6-1-9-7-6-12Z"/>' +
    '<path d="M139 64c16-12 32-12 46-4-8 13-24 20-42 16-6-2-8-8-4-12Z"/>' +
    '<path d="M129 100c17-10 33-8 46 1-9 12-26 18-43 12-6-2-8-8-3-13Z"/>' +
    '<path d="M123 136c17-9 33-6 45 4-10 11-27 15-43 8-6-3-7-9-2-12Z"/></g>' +
    '</svg></span>' +
    '<span class="deco deco-tomato" aria-hidden="true">' +
    '<svg viewBox="0 0 220 200">' +
    '<g fill="#4e8a37">' +
    '<path d="M40 120c30-26 58-30 92-16-16 26-44 40-78 34-12-2-20-10-14-18Z"/>' +
    '<path d="M96 96c8-30 26-50 54-58-2 30-16 54-40 66-9 4-17-1-14-8Z"/></g>' +
    '<circle cx="60" cy="150" r="42" fill="#d63a26"/>' +
    '<circle cx="128" cy="162" r="34" fill="#e0432b"/>' +
    '<circle cx="98" cy="120" r="24" fill="#cf3521"/>' +
    '<ellipse cx="46" cy="136" rx="12" ry="8" fill="#f08b6f" opacity=".55"/>' +
    '<ellipse cx="116" cy="150" rx="9" ry="6" fill="#f08b6f" opacity=".5"/>' +
    '<path d="M60 108l6 12 12-4-8 12 8 12-14-6-12 8 2-14-10-10 14-2Z" fill="#5c9040"/>' +
    '</svg></span>';

  /* Echte Icon-Fotos (Pommes/Ayran) aus img/. Für "cola" gibt es noch kein brauchbares
     Icon-Foto (gelieferte Datei war ein Duplikat des Pommes-Bilds) -> Platzhalter-SVG,
     bis ein echtes Cola-Icon nachgereicht wird. */
  function drinkIcon(kind) {
    var drink = kind === "cola"
      ? '<svg class="offer-icon offer-icon--drink" viewBox="0 0 40 64" aria-hidden="true">' +
        '<path d="M4 8h32l-5 52a4 4 0 0 1-4 4H13a4 4 0 0 1-4-4z" fill="#2a1a12"/>' +
        '<rect x="2" y="5" width="36" height="8" rx="3" fill="#3a2a20"/></svg>'
      : '<img class="offer-icon offer-icon--drink" src="img/ayran-icon.png" alt="Ayran" loading="eager">';
    return '<img class="offer-icon offer-icon--fries" src="img/pommes-icon.png" alt="Pommes" loading="eager">' + drink;
  }

  /* ---------- Kopfzeile ---------- */
  function buildHead() {
    var h = el("header", "masthead");

    var brand = el("div", "brand");
    var img = el("img", "logo");
    img.src = window.AKDENIZ_MENU.brand.logo; img.alt = "Akdeniz Kebap";
    brand.appendChild(img);

    var tag = el("div", "tagline");
    window.AKDENIZ_MENU.brand.tagline.forEach(function (w, i) {
      if (i) { var d = el("i", null, "·"); tag.appendChild(d); }
      tag.appendChild(el("span", null, w));
    });

    var badge = el("div", "badge");
    lines(badge, window.AKDENIZ_MENU.brand.badge);
    var u = document.createElement("span");
    u.className = "badge-underline";
    u.innerHTML = '<svg viewBox="0 0 220 24" preserveAspectRatio="none" aria-hidden="true">' +
      '<path d="M4 15 C 60 4, 150 4, 214 12 C 150 16, 70 18, 8 21 Z" fill="currentColor"/></svg>';
    badge.appendChild(u);

    h.appendChild(brand);
    h.appendChild(tag);
    h.appendChild(badge);
    return h;
  }

  /* ---------- Seite 1: Preis-Karte (Bild links, Preise rechts) ---------- */
  function buildMatrixCard(c) {
    var card = el("article", "card card--photo");

    var main = el("div", "card-main");

    var head = el("div", c.titleImage ? "card-head card-head--image" : "card-head");
    if (c.titleImage) {
      var timg = el("img", "card-title-img");
      timg.src = c.titleImage; timg.alt = c.title || ""; timg.loading = "eager";
      head.appendChild(timg);
    } else {
      var h2 = el("h2", "card-title"); h2.textContent = c.title;
      var sub = el("p", "card-sub", c.subtitle);
      head.appendChild(h2); head.appendChild(sub);
    }
    main.appendChild(head);

    var note = el("div", "card-note");
    var nt = el("span", "note-text"); lines(nt, c.note);
    note.appendChild(nt);
    note.insertAdjacentHTML("beforeend", ARROW);
    main.appendChild(note);

    var media = el("div", "card-media");
    media.insertAdjacentHTML("beforeend", SWASH);
    var pi = el("img", "food"); pi.src = c.image; pi.alt = c.title; pi.loading = "eager";
    media.appendChild(pi);
    main.appendChild(media);

    card.appendChild(main);

    if (c.tiles) {
      var box = el("div", "card-prices");
      if (c.portion) box.appendChild(el("p", "portion", c.portion));
      var tiles = el("div", "tiles");
      c.tiles.forEach(function (t) {
        var tl = el("div", "tile" + (t.mix ? " is-mix" : ""));
        tl.appendChild(el("div", "t-label", t.label));
        tl.appendChild(el("div", "t-price", t.price));
        tiles.appendChild(tl);
      });
      box.appendChild(tiles);
      card.appendChild(box);
      return card;
    }

    var table = el("table", "matrix");
    var thead = el("thead");
    var tr = el("tr");
    tr.appendChild(el("th", "c-size", c.head));
    tr.appendChild(el("th", null, "Hähnchen"));
    tr.appendChild(el("th", null, "Steak"));
    var thm = el("th", "mix"); lines(thm, "Fleisch-\nMix"); tr.appendChild(thm);
    thead.appendChild(tr); table.appendChild(thead);

    var tb = el("tbody");
    c.rows.forEach(function (r) {
      var row = el("tr");
      var td0 = el("td", "c-size");
      td0.appendChild(el("b", null, r.label));
      if (r.sub) td0.appendChild(el("small", null, " " + r.sub));
      row.appendChild(td0);
      row.appendChild(el("td", null, r.haehnchen));
      row.appendChild(el("td", null, r.steak));
      row.appendChild(el("td", "mix", r.mix));
      tb.appendChild(row);
    });
    table.appendChild(tb);
    card.appendChild(table);
    return card;
  }

  /* ---------- Seite 2: Listen-Karte ---------- */
  function buildListCard(c) {
    var card = el("article", "card card--list");
    var head = el("div", "card-head");
    var h2 = el("h2", "card-title"); h2.textContent = c.title;
    head.appendChild(h2);
    if (c.subtitle) head.appendChild(el("p", "card-sub", c.subtitle));
    card.appendChild(head);

    var list = el("div", "list");
    c.list.forEach(function (it) {
      var row = el("div", "item");
      row.appendChild(el("span", "name", it.name));
      row.appendChild(el("span", "dots"));
      row.appendChild(el("span", "price", it.price));
      list.appendChild(row);
    });
    card.appendChild(list);
    return card;
  }

  /* ---------- Seite 1: Menü-Balken ---------- */
  function buildMenuBar(m) {
    var bar = el("aside", "menu-cta");

    var left = el("div", "cta-text");
    var t = el("div", "cta-title");
    t.appendChild(el("span", null, m.title));
    var p = el("p", "cta-sub", m.text);
    left.appendChild(t); left.appendChild(p);

    var offers = el("div", "cta-offers");
    m.offers.forEach(function (o, i) {
      if (i) offers.appendChild(el("span", "cta-div"));
      var box = el("div", "offer");
      box.insertAdjacentHTML("beforeend", drinkIcon(o.icon));
      var txt = el("div", "offer-txt");
      txt.appendChild(el("span", "offer-label", o.label));
      txt.appendChild(el("span", "offer-price", o.price));
      box.appendChild(txt);
      offers.appendChild(box);
    });

    bar.appendChild(left);
    bar.appendChild(offers);
    return bar;
  }

  function buildFoot(arr) {
    var f = el("footer", "foot");
    f.appendChild(el("span", null, arr[0]));
    f.appendChild(el("span", "r", arr[1]));
    return f;
  }

  /* ---------- Zusammenbau ---------- */
  var board = document.getElementById("board");
  function render(DATA) {
    window.AKDENIZ_MENU = DATA;
    var D = DATA[page];
    if (!D) return;

    board.insertAdjacentHTML("beforeend", DECO);
    board.appendChild(buildHead());

    var grid = el("main", "grid");
    D.cards.forEach(function (c) {
      grid.appendChild(page === "seite1" ? buildMatrixCard(c) : buildListCard(c));
    });
    board.appendChild(grid);

    if (D.menu) board.appendChild(buildMenuBar(D.menu));
    board.appendChild(buildFoot(D.foot));
  }

  fetch("content/menu.json")
    .then(function (r) { return r.json(); })
    .then(render)
    .catch(function (err) { console.error("Menü konnte nicht geladen werden:", err); });
})();
