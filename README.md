# 💳 Credit Card Transactions SQL Analysis

This project analyzes a sample dataset of credit card transactions to uncover key insights using SQL. It simulates a real-world use case of monitoring financial activity for trends and citywise behavior analysis.

---

## 📁 Project Structure

credit-card-transaction-analysis/  
├── queries/        → All SQL queries for KPIs and analysis
├── schema/         → Table creation scripts and sample data
├── insights/       → Summary of important KPI and insight
└── README.md       → Project overview and documentation

---

## 📊 Key KPIs and Metrics

1. **Top 5 cities with highest spend**  
2. **Highest spend month**  
3. **MoM growth in Jan 2024**  
4. **Monthly Transaction Trends**  
5. **Lowest Gold card spending**

👉 See the [`queries/`](./queries/tested_queries.sql) folder for individual SQL files.  
👉 Insights are explained in [`insights/project-insights.md`](./insights/project-insights.md).

---

## 🛠️ Tools Used

- PostgreSQL
- SQL

---

## 📌 How to Use

1. Clone the repository:
   ```bash git clone
   https://github.com/vikassyn94/cc-transaction-sql-project.git
   
2. Open your PostgreSQL client (like pgAdmin or DBeaver)

3. Execute:
- `schema/create_tables.sql` to create the database structure
- `schema/Credit card transactions - India - Simple.csv` to insert sample data into the tables
- Run queries in `/queries/tested_queries.sql` to generate KPIs

---

## 🧠 Insights

- Over 50% of total expenditure is contributed by users from the top 5 cities.
- January accounts for nearly 50% of the total transaction value across the year, indicating a significant seasonal spike.
- Female customers spend the most on bill payments, making it their highest expenditure category.

---

## 🙋‍♂️ Author

**Vikas Singh**  
📫 [vsre94@gmail.com](mailto:vsre94@gmail.com)  
🔗 [LinkedIn Profile](https://www.linkedin.com/in/vikas-singh-0856421b2/)

---

## 📄 License

This project is open for educational and portfolio use. Contact the author for any reuse or collaboration.
