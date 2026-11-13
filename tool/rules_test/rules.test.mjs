import { initializeTestEnvironment, assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import { doc, getDoc, setDoc, updateDoc, deleteDoc, collection, query, where, getDocs, orderBy } from 'firebase/firestore';
import { readFileSync } from 'node:fs';

const env = await initializeTestEnvironment({
  projectId: 'demo-ofc',
  firestore: { rules: readFileSync(new URL('../../firestore.rules', import.meta.url), 'utf8'), host: '127.0.0.1', port: 8080 },
});
await env.withSecurityRulesDisabled(async (ctx) => {
  const db = ctx.firestore();
  await setDoc(doc(db, 'users/admin1'), { name: 'Ada', role: 'admin' });
  await setDoc(doc(db, 'users/cust1'), { name: 'Cy', role: 'customer' });
  await setDoc(doc(db, 'users/cust2'), { name: 'Di', role: 'customer' });
  await setDoc(doc(db, 'cars/car1'), { make: 'BMW', price: 50000, status: 'available' });
  await setDoc(doc(db, 'cars/car2'), { make: 'Audi', price: 70000, status: 'sold' });
  await setDoc(doc(db, 'offers/off1'), { userId: 'cust1', carId: 'car1', amount: 45000, status: 'accepted', reply: '' });
  await setDoc(doc(db, 'offers/off2'), { userId: 'cust2', carId: 'car1', amount: 40000, status: 'accepted', reply: '' });
  await setDoc(doc(db, 'offers/off3'), { userId: 'cust1', carId: 'car1', amount: 30000, status: 'pending', reply: '' });
  await setDoc(doc(db, 'orders/ord1'), { userId: 'cust1', carId: 'car1', price: 50000, status: 'pending' });
  await setDoc(doc(db, 'orders/ord2'), { userId: 'cust1', carId: 'car1', price: 50000, status: 'confirmed' });
});
const admin = env.authenticatedContext('admin1').firestore();
const c1 = env.authenticatedContext('cust1').firestore();
const c2 = env.authenticatedContext('cust2').firestore();
const anon = env.unauthenticatedContext().firestore();
const order = (o) => ({ userId: 'cust1', carId: 'car1', price: 50000, status: 'pending', offerId: null, ...o });

const cases = [
  ['anon cannot read cars', assertFails(getDoc(doc(anon, 'cars/car1')))],
  ['customer reads cars', assertSucceeds(getDoc(doc(c1, 'cars/car1')))],
  ['customer cannot edit a car', assertFails(updateDoc(doc(c1, 'cars/car1'), { price: 1 }))],
  ['admin edits a car', assertSucceeds(updateDoc(doc(admin, 'cars/car1'), { featured: true }))],
  ['customer cannot make self admin', assertFails(updateDoc(doc(c1, 'users/cust1'), { role: 'admin' }))],
  ['customer updates own name', assertSucceeds(setDoc(doc(c1, 'users/cust1'), { name: 'Cy 2', phone: '1' }, { merge: true }))],
  ['cannot sign up as admin', assertFails(setDoc(doc(env.authenticatedContext('new1').firestore(), 'users/new1'), { name: 'x', role: 'admin' }))],
  ['can sign up as customer', assertSucceeds(setDoc(doc(env.authenticatedContext('new2').firestore(), 'users/new2'), { name: 'x', role: 'customer' }))],
  ['cannot read another profile', assertFails(getDoc(doc(c2, 'users/cust1')))],
  ['admin reads a profile', assertSucceeds(getDoc(doc(admin, 'users/cust1')))],
  ['own favorites', assertSucceeds(setDoc(doc(c1, 'users/cust1/favorites/car1'), { a: 1 }))],
  ['not others favorites', assertFails(setDoc(doc(c2, 'users/cust1/favorites/car1'), { a: 1 }))],
  ['create own pending offer', assertSucceeds(setDoc(doc(c1, 'offers/n1'), { userId: 'cust1', carId: 'car1', amount: 100, status: 'pending', reply: '' }))],
  ['cannot create pre-accepted offer', assertFails(setDoc(doc(c1, 'offers/n2'), { userId: 'cust1', carId: 'car1', amount: 100, status: 'accepted', reply: '' }))],
  ['cannot create offer as someone else', assertFails(setDoc(doc(c1, 'offers/n3'), { userId: 'cust2', carId: 'car1', amount: 100, status: 'pending', reply: '' }))],
  ['cannot accept own offer', assertFails(updateDoc(doc(c1, 'offers/off3'), { status: 'accepted' }))],
  ['admin accepts offer', assertSucceeds(updateDoc(doc(admin, 'offers/off3'), { status: 'declined', reply: 'no' }))],
  ['customer lists own offers', assertSucceeds(getDocs(query(collection(c1, 'offers'), where('userId', '==', 'cust1'))))],
  ['customer cannot list all offers', assertFails(getDocs(collection(c1, 'offers')))],
  ['admin lists all offers', assertSucceeds(getDocs(collection(admin, 'offers')))],
  ['order at list price', assertSucceeds(setDoc(doc(c1, 'orders/n1'), order({})))],
  ['order without offerId field', assertSucceeds(setDoc(doc(c1, 'orders/n1b'), { userId: 'cust1', carId: 'car1', price: 50000, status: 'pending' }))],
  ['order at made-up price', assertFails(setDoc(doc(c1, 'orders/n2'), order({ price: 1 })))],
  ['order at own accepted offer price', assertSucceeds(setDoc(doc(c1, 'orders/n3'), order({ price: 45000, offerId: 'off1' })))],
  ['order using someone elses offer', assertFails(setDoc(doc(c1, 'orders/n4'), order({ price: 40000, offerId: 'off2' })))],
  ['order using pending offer', assertFails(setDoc(doc(c1, 'orders/n5'), order({ price: 30000, offerId: 'off3' })))],
  ['order for a sold car', assertFails(setDoc(doc(c1, 'orders/n6'), order({ carId: 'car2', price: 70000 })))],
  ['order created as confirmed', assertFails(setDoc(doc(c1, 'orders/n7'), order({ status: 'confirmed' })))],
  ['order for someone else', assertFails(setDoc(doc(c1, 'orders/n8'), order({ userId: 'cust2' })))],
  ['customer cannot confirm own order', assertFails(updateDoc(doc(c1, 'orders/ord1'), { status: 'confirmed' }))],
  ['customer cannot change price while cancelling', assertFails(updateDoc(doc(c1, 'orders/ord1'), { status: 'cancelled', price: 1 }))],
  ['customer cannot cancel a confirmed order', assertFails(updateDoc(doc(c1, 'orders/ord2'), { status: 'cancelled' }))],
  ['other customer cannot read order', assertFails(getDoc(doc(c2, 'orders/ord1')))],
  ['other customer cannot cancel order', assertFails(updateDoc(doc(c2, 'orders/ord1'), { status: 'cancelled' }))],
  ['admin confirms order', assertSucceeds(updateDoc(doc(admin, 'orders/ord2'), { status: 'completed' }))],
];
let failed = 0;
for (const [name, p] of cases) {
  try { await p; console.log('ok   ', name); } catch (e) { failed++; console.log('FAIL ', name, '-', e.message.split('\n')[0]); }
}
// runs last because it changes ord1
try { await assertSucceeds(updateDoc(doc(c1, 'orders/ord1'), { status: 'cancelled', updatedAt: 1 })); console.log('ok    customer cancels own pending order'); } catch (e) { failed++; console.log('FAIL  customer cancels own pending order', e.message.split('\n')[0]); }
await env.cleanup();
console.log(failed ? `${failed} FAILED` : 'ALL RULES TESTS PASSED');
process.exit(failed ? 1 : 0);
