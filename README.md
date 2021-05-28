# Intelligent-Solar-Energy-Manager
I'm working on a device that will manage the house energy consumption, according to the expected photovoltaic energy production and the electricity prices in the Spanish market.

In a building we can say, to keep thing simple, that we have 2 different kinds of load. Must-run loads, like TV, and deferrable loads, like a washing machine. So, the idea of the device is to turn on the deferrable load on the most efficient way possible.

To sum-up the project, we will try to predict the solar energy production and the household energy consumption using machine learning techniques.

Once, we have made our forecast, we will get the electricIty prices. Then, we will call a Matlab function that will apply a linear programming algorithm to distribute the energy on the most efficient way from an economic point of view.
