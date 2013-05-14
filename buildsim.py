import random

buildings = []
current_turn = 0
queued_shipments = []
MAX_SHIPMENT = 10

from fractions import Fraction

messages = []

def queue_shipment(source, amount, target, turns):
    messages.append("Shipping {0} from {1} to {2}".format(amount, source.name, target.name))
    queued_shipments.append((amount, target, current_turn + turns))
    source.level -= amount
    target.inflight += amount

class ScreenClearer:
    def __repr__(self):
        import os
        os.system('cls' if os.name == 'nt' else 'clear')
        return ''

cls = ScreenClearer()

class Building:
    def __init__(self, name):
        self.name = name
        self.level = 0
        self.usage = 0
        self.position = 0
        self.inflight = 0
        self.warehouse = False
        self.generation = None
        self._period = 0
        self.operating = False
        self._demand_bias = 0
        self.capacity = 500

    @property
    def demand(self):
        if self.warehouse:
            return 25
        source = None
        for building in buildings:
            if building.warehouse:
                source = building
                break
        else:
            # Guess!
            return 3*self.usage + self._demand_bias
        return int(self.usage * (3 + abs(self.position - source.position)//3) * 1.6) + self._demand_bias

    def tick(self, n):
        self.operating = True
        if self.generation is not None:
            if self.level >= self.usage:
                self.level -= self.usage
                self._period += 1
                (production, period) = self.generation
                if self._period > period:
                    self.level += production
                    self._period = 0
                    messages.append("Produced {0} at {1}".format(production, self.name))
            else:
                self.operating = False
        else:
            if self.warehouse and self.level < self.usage:
                print("Out of food.")
                exit(0)
            elif self.level >= self.usage:
                self.level -= self.usage
            else:
                self.operating = False
        if not self.operating and random.random() < 0.35:
            self._demand_bias += 1
        if self.operating and self._demand_bias > 0 and random.random() < 0.002:
            self._demand_bias -= 1
        if self.level > self.capacity:
            messages.append("{0} dumping {1} units due to overcapacity".format(self.name, self.level - self.capacity))
            self.level = self.capacity
        if self.level <= self.demand:
            return
        possible_targets = []
        for bld in buildings:
            if bld is self:
                continue
            if random.random() < 0.65:
                possible_targets.append(bld)
        targets = list(sorted(possible_targets, key = lambda x: abs(self.position - x.position)))
        for potential in targets:
            if potential.level + potential.inflight < potential.demand:
                # ship to them
                amount = min(self.level - self.demand, int((potential.demand - potential.level) * 1.5), MAX_SHIPMENT)
                queue_shipment(self, amount, potential, abs(potential.position - self.position) // 3)
                break
        else:
            if random.random() < 0.3:
                # ship to a warehouse
                for potential in targets:
                    if potential.warehouse:
                        amount = min(self.level - self.demand, MAX_SHIPMENT)
                        queue_shipment(self, amount, potential, abs(potential.position - self.position) // 3)
                        break

hq = Building('HQ')
hq.level = 30
hq.usage = 1
hq.warehouse = True
hq.position = 0

farm1 = Building('Farm')
farm1.generation = (10, 7)
farm1.position = 6

farm2 = Building('Farm')
farm2.level = 300
farm2.position = -10
farm2.generation = (10, 7)

farm3 = Building('Farm')
farm3.position = -22
farm3.generation = (10, 7)

farm4 = Building('Pig Farm')
farm4.position = -44
farm4.generation = (3, 1)

passive = Building('Forager')
passive.position = -70
passive.generation = (1, 5)

workhouse = Building('Workhouse')
workhouse.position = 40
workhouse.usage = 2

forester = Building('Forester')
forester.position = 4
forester.usage = 1

woodcutter = Building('Woodcutter')
woodcutter.position = 6
woodcutter.usage = 1

buildings.extend([hq, farm1, farm2, farm3, farm4, passive, workhouse, forester, woodcutter])

import sys
import time

while True:
    print(cls)
    # Calculate totals
    total_demand = 0
    total_supply = 0

    for bld in buildings:
        total_demand += bld.usage
        if bld.generation is not None:
            production, period = bld.generation
            total_supply += Fraction(production, period)

    if total_supply == total_demand:
        print("INFO: Supply matches demand.")
    else:
        if total_supply > total_demand:
            print("WARNING: supply exceeds demand, will stockpile until eternity")
        elif total_supply < total_demand:
            print("WARNING: demand exceeds supply, will starve")
        print("Supply: {0}".format(float(total_supply)))
        print("Demand: {0}".format(float(total_demand)))

    # process deliveries
    new_deliveries = []
    for (amount, target, due) in queued_shipments:
        if due <= current_turn:
            target.level += amount
            target.inflight -= amount
        else:
            new_deliveries.append((amount, target, due))
    queued_shipments = new_deliveries
    # tick buildings
    for building in buildings:
        building.tick(current_turn)
    # display
    for building in buildings:
        print("{0}{2}\t\t{1}\t[demand = {3}]".format(building.name, building.level, '' if building.operating else '[x]', building.demand))
    for message in messages:
        print(message)
    messages.clear()
    # increment turn counter
    current_turn += 1
    # Sleep
    sys.stdout.flush()
    time.sleep(0.05)

