import pandas as pd
import matplotlib.pyplot as plt
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent.parent

TABLES_DIR = BASE_DIR / "outputs" / "tables"
FIGURES_DIR = BASE_DIR / "outputs" / "figures"

FIGURES_DIR.mkdir(parents=True, exist_ok=True)

country = pd.read_csv(
    TABLES_DIR / "country_performance.csv"
)

country = country.sort_values(
    "revenue",
    ascending=True
)

fig, ax = plt.subplots(figsize=(10, 6))

ax.barh(
    country["country"],
    country["revenue"]
)

ax.set_title("Revenue by Country")
ax.set_xlabel("Revenue (€)")
ax.set_ylabel("Country")

for i, value in enumerate(country["revenue"]):
    ax.text(
        value,
        i,
        f"€{value:,.0f}",
        va="center",
        ha="left"
    )

plt.tight_layout()

plt.savefig(
    FIGURES_DIR / "revenue_by_country.png",
    dpi=300,
    bbox_inches="tight"
)

plt.show()

category = pd.read_csv(
    TABLES_DIR / "category_profitability.csv"
)

category = category.sort_values(
    "revenue",
    ascending=True
)

fig, ax = plt.subplots(figsize=(10, 6))

y = range(len(category))

ax.barh(
    [i - 0.2 for i in y],
    category["revenue"],
    height=0.4,
    label="Revenue"
)

ax.barh(
    [i + 0.2 for i in y],
    category["estimated_gross_profit"],
    height=0.4,
    label="Estimated Gross Profit"
)

ax.set_yticks(list(y))
ax.set_yticklabels(category["category"])

ax.set_title("Revenue and Estimated Gross Profit by Category")
ax.set_xlabel("€")
ax.set_ylabel("Category")
ax.legend()

plt.tight_layout()

plt.savefig(
    FIGURES_DIR / "category_profitability.png",
    dpi=300,
    bbox_inches="tight"
)

plt.show()

products = pd.read_csv(
    TABLES_DIR / "top_products.csv"
)

products = products.sort_values(
    "revenue",
    ascending=True
)

fig, ax = plt.subplots(figsize=(11, 7))

ax.barh(
    products["product_name"],
    products["revenue"]
)

ax.set_title("Top 10 Products by Revenue")
ax.set_xlabel("Revenue (€)")
ax.set_ylabel("Product")

for i, value in enumerate(products["revenue"]):
    ax.text(
        value,
        i,
        f"€{value:,.0f}",
        va="center",
        ha="left"
    )

plt.tight_layout()

plt.savefig(
    FIGURES_DIR / "top_products.png",
    dpi=300,
    bbox_inches="tight"
)

plt.show()

rfm = pd.read_csv(
    TABLES_DIR / "rfm_segments.csv"
)

rfm = rfm.sort_values(
    "total_revenue",
    ascending=True
)

fig, ax = plt.subplots(figsize=(10, 6))

ax.barh(
    rfm["customer_segment"],
    rfm["total_revenue"]
)

ax.set_title("Revenue by Customer Segment")
ax.set_xlabel("Revenue (€)")
ax.set_ylabel("Customer Segment")

for i, value in enumerate(rfm["total_revenue"]):
    ax.text(
        value,
        i,
        f"€{value:,.0f}",
        va="center",
        ha="left"
    )

plt.tight_layout()

plt.savefig(
    FIGURES_DIR / "rfm_segments.png",
    dpi=300,
    bbox_inches="tight"
)

plt.show()

discount = pd.read_csv(
    TABLES_DIR / "discount_performance.csv"
)

discount["discount_numeric"] = (
    discount["discount_percent"]
    .str.replace("%", "", regex=False)
    .astype(float)
)

discount = discount.sort_values(
    "discount_numeric"
)

fig, ax = plt.subplots(figsize=(9, 6))

bars = ax.bar(
    discount["discount_percent"],
    discount["gross_margin_pct"]
)

ax.set_title("Estimated Gross Margin by Discount Level")
ax.set_xlabel("Discount")
ax.set_ylabel("Estimated Gross Margin (%)")

for bar, value in zip(
    bars,
    discount["gross_margin_pct"]
):
    ax.text(
        bar.get_x() + bar.get_width() / 2,
        bar.get_height(),
        f"{value:.1f}%",
        ha="center",
        va="bottom"
    )

plt.tight_layout()

plt.savefig(
    FIGURES_DIR / "discount_margin.png",
    dpi=300,
    bbox_inches="tight"
)

plt.show()