/* ================================================================
   Akdeniz Kebap – Renderer
   Baut die Speisekarte aus content/menu.json (per CMS bearbeitbar). Kein Framework.
   <body data-page="seite1"> oder "seite2" steuert, was gebaut wird.
   ================================================================ */
(function () {
  "use strict";
  var page = document.body.dataset.page;
  var IMG_BASE = document.body.dataset.imgBase || "img/";

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

  /* Echte Icon-Fotos (Pommes/Ayran) aus img/. Für "cola" gibt es kein Produktfoto
     (markenfrei gehalten) -> handgezeichnetes Becher-Icon im selben Look. */
  var COLA_ICON =
    '<svg class="offer-icon offer-icon--drink" viewBox="0 0 44 84" aria-hidden="true">' +
    '<ellipse cx="22" cy="26.5" rx="16" ry="3.4" fill="#8f160f"/>' +
    '<path d="M6,26 L38,26 L31,82 Q31,84.5 28.5,84.5 L15.5,84.5 Q13,84.5 13,82 Z" fill="#c62418"/>' +
    '<path d="M6,26 L17,26 L14.5,82.5 Q13,82 13,80.5 Z" fill="#e5483a" opacity=".55"/>' +
    '<path d="M30,26 L38,26 L31,82 Q30.6,83.7 29.3,84.2 Z" fill="#8f160f" opacity=".45"/>' +
    '<path d="M11,29 C9.7,45 9.9,63 12,81" stroke="#8f160f" stroke-width="1" fill="none" opacity=".3"/>' +
    '<path d="M33,29 C34.3,45 34.1,63 32,81" stroke="#8f160f" stroke-width="1" fill="none" opacity=".3"/>' +
    '<path d="M9.5,43 L34.5,43 L32.6,63 L11.4,63 Z" fill="#fff" opacity=".96"/>' +
    '<text x="22" y="56.5" text-anchor="middle" font-family="Georgia, \'Times New Roman\', serif" ' +
    'font-style="italic" font-weight="700" font-size="12.5" fill="#c62418">Cola</text>' +
    '<ellipse cx="17" cy="51" rx="1.5" ry="2.6" fill="#fff" opacity=".4"/>' +
    '<ellipse cx="29" cy="67" rx="1.2" ry="2.1" fill="#fff" opacity=".35"/>' +
    '<path d="M5.5,26 Q22,9 38.5,26 Q22,21.5 5.5,26 Z" fill="#f4f4f4"/>' +
    '<path d="M5.5,26 Q22,9 38.5,26 Q22,23 5.5,26 Z" fill="#fff"/>' +
    '<path d="M13,22.5 Q22,15 31,22.5" stroke="#d9d9d9" stroke-width="1" fill="none" opacity=".7"/>' +
    '<ellipse cx="22" cy="26.3" rx="16" ry="3" fill="#fdfdfd"/>' +
    '<g transform="translate(25,17) rotate(-24)">' +
    '<rect x="-1.6" y="-27" width="3.2" height="29" rx="1.6" fill="#fff"/>' +
    '<rect x="-1.6" y="-27" width="3.2" height="29" rx="1.6" fill="none" stroke="#d6261b" stroke-width="2.6" stroke-dasharray="2.8 4.2"/>' +
    '</g>' +
    '<circle cx="36.5" cy="7" r="1.3" fill="#fff" opacity=".85"/>' +
    '<circle cx="39.5" cy="13.5" r="0.9" fill="#fff" opacity=".65"/>' +
    '<circle cx="34" cy="2.5" r="0.8" fill="#fff" opacity=".55"/>' +
    '</svg>';

  function drinkIcon(kind) {
    var drink = kind === "cola"
      ? COLA_ICON
      : '<img class="offer-icon offer-icon--drink" src="' + IMG_BASE + 'ayran-icon.png" alt="Ayran" loading="eager">';
    return '<img class="offer-icon offer-icon--fries" src="' + IMG_BASE + 'pommes-icon.png" alt="Pommes" loading="eager">' + drink;
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

  /* ---------- Gemeinsam: Titel(-Bild) + Notiz + Produktfoto ---------- */
  function buildCardMain(c) {
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

    if (c.note) {
      var note = el("div", "card-note");
      var nt = el("span", "note-text"); lines(nt, c.note);
      note.appendChild(nt);
      note.insertAdjacentHTML("beforeend", ARROW);
      main.appendChild(note);
    }

    if (c.image) {
      var media = el("div", "card-media");
      var pi = el("img", "food"); pi.src = c.image; pi.alt = c.title; pi.loading = "eager";
      media.appendChild(pi);
      main.appendChild(media);
    }

    return main;
  }

  function buildTilesBox(c) {
    var box = el("div", "card-prices");
    if (c.portion) box.appendChild(el("p", "portion", c.portion));
    var tiles = el("div", "tiles");
    c.tiles.forEach(function (t) {
      var kind = t.kind || (t.mix ? "is-mix" : t.label === "Hähnchen" ? "haehnchen" : t.label === "Steak" ? "steak" : "");
      var tl = el("div", ("tile " + kind).trim());
      tl.appendChild(el("div", "t-label", t.label));
      tl.appendChild(el("div", "t-price", t.price));
      tiles.appendChild(tl);
    });
    box.appendChild(tiles);
    return box;
  }

  /* ---------- Seite 1: Preis-Karte (Bild links, Preise rechts) ---------- */
  function buildMatrixCard(c) {
    var card = el("article", "card card--photo");
    card.appendChild(buildCardMain(c));

    if (c.tiles) {
      card.appendChild(buildTilesBox(c));
      return card;
    }

    var table = el("table", "matrix");
    var thead = el("thead");
    var tr = el("tr");
    tr.appendChild(el("th", "c-size", c.head));
    tr.appendChild(el("th", "haehnchen", "Hähnchen"));
    tr.appendChild(el("th", "steak", "Steak"));
    var thm = el("th", "mix"); lines(thm, "Fleisch-\nMix"); tr.appendChild(thm);
    thead.appendChild(tr); table.appendChild(thead);

    var tb = el("tbody");
    c.rows.forEach(function (r) {
      var row = el("tr");
      var td0 = el("td", "c-size");
      td0.appendChild(el("b", null, r.label));
      if (r.sub) td0.appendChild(el("small", null, " " + r.sub));
      row.appendChild(td0);
      row.appendChild(el("td", "haehnchen", r.haehnchen));
      row.appendChild(el("td", "steak", r.steak));
      row.appendChild(el("td", "mix", r.mix));
      tb.appendChild(row);
    });
    table.appendChild(tb);
    card.appendChild(table);
    return card;
  }

  function buildPriceList(c) {
    var list = el("div", "list");
    c.list.forEach(function (it) {
      var row = el("div", "item");
      /* optionales Mini-Bild links vom Namen. Feld fehlt: nur Name + Preis.
         Feld leer: runder Platzhalter (Bild folgt). */
      if ("image" in it) {
        var thumb = el("span", it.image ? "thumb" : "thumb is-empty");
        if (it.image) {
          var ti = el("img"); ti.src = it.image; ti.alt = ""; ti.loading = "eager";
          thumb.appendChild(ti);
        }
        row.appendChild(thumb);
      }
      row.appendChild(el("span", "name", it.name));
      row.appendChild(el("span", "price", it.price));
      list.appendChild(row);
    });
    return list;
  }

  /* ---------- Listen-Karte: mit Produktfoto (Bild links, Liste rechts) ODER
     ohne Foto (volle Breite, nur Liste – Standard auf Seite 2) ---------- */
  function buildListCard(c) {
    if (c.image) {
      var pcard = el("article", "card card--photo");
      pcard.appendChild(buildCardMain(c));
      var box = el("div", "card-prices");
      box.appendChild(buildPriceList(c));
      pcard.appendChild(box);
      return pcard;
    }

    var card = el("article", "card card--list");
    var head = el("div", "card-head");
    var h2 = el("h2", "card-title"); h2.textContent = c.title;
    head.appendChild(h2);
    if (c.subtitle) head.appendChild(el("p", "card-sub", c.subtitle));
    card.appendChild(head);
    card.appendChild(buildPriceList(c));
    return card;
  }

  /* ---------- Kacheln ohne Foto, volle Breite (z.B. normale Pizza Seite 2) ---------- */
  function buildTilesOnlyCard(c) {
    var card = el("article", "card card--list card--tiles-only");
    var head = el("div", "card-head");
    var h2 = el("h2", "card-title"); h2.textContent = c.title;
    head.appendChild(h2);
    if (c.subtitle) head.appendChild(el("p", "card-sub", c.subtitle));
    card.appendChild(head);
    card.appendChild(buildTilesBox(c));
    return card;
  }

  /* ---------- Produkt-Raster: jedes Produkt mit eigenem Bild oben, darunter
     Name + Preis (z.B. Falafel & Halloumi, Pizzen). Fehlt das Bild noch,
     steht ein dezenter Platzhalter an seiner Stelle. ---------- */
  var PLACEHOLDER = '<svg class="g-ph" viewBox="0 0 64 64" aria-hidden="true">' +
    '<circle cx="32" cy="34" r="20" fill="none" stroke="currentColor" stroke-width="3"/>' +
    '<circle cx="32" cy="34" r="12" fill="none" stroke="currentColor" stroke-width="2" opacity=".6"/>' +
    '<path d="M8 10v14M4 10v10a4 4 0 0 0 8 0V10M8 24v30M56 10c-5 3-6 10-6 16h6v28" fill="none" ' +
    'stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"/></svg>';

  function buildGalleryCard(c) {
    var card = el("article", "card card--gallery");
    var head = el("div", "card-head");
    var h2 = el("h2", "card-title"); h2.textContent = c.title;
    head.appendChild(h2);
    if (c.subtitle) head.appendChild(el("p", "card-sub", c.subtitle));
    card.appendChild(head);

    var gal = el("div", "gallery");
    c.gallery.forEach(function (it) {
      var item = el("div", ("g-item " + (it.kind || "")).trim());
      var media = el("div", "g-media");
      if (it.image) {
        var img = el("img", "g-img");
        img.src = it.image; img.alt = it.name; img.loading = "eager";
        media.appendChild(img);
      } else {
        media.classList.add("is-empty");
        media.insertAdjacentHTML("beforeend", PLACEHOLDER);
      }
      item.appendChild(media);
      item.appendChild(el("div", "g-name", it.name));
      item.appendChild(el("div", "g-price", it.price));
      gal.appendChild(item);
    });
    card.appendChild(gal);
    return card;
  }

  /* Seite 2: Karten in zwei Reihen verteilen. Produkt-Raster zählen doppelt so
     breit wie Listen; die Reihen werden so geteilt, dass beide möglichst
     gleich viel Gewicht tragen. */
  function buildRows(nodes, cards) {
    var w = cards.map(function (c) { return c.gallery ? 2 : 1; });
    var total = w.reduce(function (a, b) { return a + b; }, 0);
    var cut = 1, best = Infinity, sum = 0;
    for (var i = 0; i < w.length - 1; i++) {
      sum += w[i];
      if (Math.abs(sum * 2 - total) < best) { best = Math.abs(sum * 2 - total); cut = i + 1; }
    }
    /* Festes Spalten-Raster: beide Reihen teilen sich dieselben Spalten,
       dadurch fluchten alle Kartenkanten. Die letzte Karte einer kürzeren
       Reihe füllt den Rest auf. */
    var rowSum = [0, 0];
    w.forEach(function (x, i) { rowSum[i < cut ? 0 : 1] += x; });
    var cols = Math.max(rowSum[0], rowSum[1]);
    var grid = el("main", "grid grid--rows");
    grid.style.gridTemplateColumns = "repeat(" + cols + ", minmax(0, 1fr))";
    nodes.forEach(function (n, i) {
      var r = i < cut ? 0 : 1;
      var last = i === cut - 1 || i === nodes.length - 1;
      var span = w[i] + (last ? cols - rowSum[r] : 0);
      n.style.gridColumn = "span " + span;
      grid.appendChild(n);
    });
    return grid;
  }

  /* ---------- Seite 2: Zusatzstoffe & Allergene (eigene Kachel, unten) ---------- */
  function buildInfoCard(info) {
    var card = el("article", "card card--info");
    if (info.title) card.appendChild(el("h2", "info-title", info.title));

    var cols = el("div", "info-cols");
    function col(label, items) {
      if (!items || !items.length) return;
      var c = el("div", "info-col");
      c.appendChild(el("h3", null, label));
      var p = el("p");
      items.forEach(function (it, i) {
        p.appendChild(el("b", null, it.n));
        p.appendChild(document.createTextNode(" " + it.text));
        if (i < items.length - 1) p.appendChild(document.createTextNode(" · "));
      });
      c.appendChild(p);
      cols.appendChild(c);
    }
    col("Zusatzstoffe", info.additives);
    col("Allergene", info.allergens);
    card.appendChild(cols);
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

    var nodes = D.cards.map(function (c) {
      return c.gallery ? buildGalleryCard(c)
        : c.list ? buildListCard(c)
        : (c.tiles && !c.image) ? buildTilesOnlyCard(c)
        : buildMatrixCard(c);
    });
    var hasGallery = D.cards.some(function (c) { return c.gallery; });
    var grid;
    if (hasGallery || document.body.dataset.page === "seite2") {
      grid = buildRows(nodes, D.cards);
    } else {
      grid = el("main", "grid");
      nodes.forEach(function (n) { grid.appendChild(n); });
    }
    board.appendChild(grid);

    if (D.menu) board.appendChild(buildMenuBar(D.menu));
    if (D.info) board.appendChild(buildInfoCard(D.info));
    board.appendChild(buildFoot(D.foot));
  }

  fetch(document.body.dataset.source || "content/menu.json")
    .then(function (r) { return r.json(); })
    .then(render)
    .catch(function (err) { console.error("Menü konnte nicht geladen werden:", err); });
})();
