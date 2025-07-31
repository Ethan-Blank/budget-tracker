export default function TransactionList({ transactions }) {
  return (
    <ul>
      {transactions.map((tx) => (
        <li key={tx.id}>
          {tx.category} – ${tx.amount} on {new Date(tx.timestamp).toLocaleString()}
        </li>
      ))}
    </ul>
  );
}
