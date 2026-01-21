<?php

namespace App\Http\Controllers;

use App\Models\Keranjang;
use Illuminate\Http\Request;

class KeranjangController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        return Keranjang::all();
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        $request->validate([
            'meja' => 'required|string',
            'nama_pelanggan' => 'required|string',
        ]);

        $keranjang = Keranjang::create($request->all());
        return response()->json($keranjang, 201);
    }

    /**
     * Display the specified resource.
     */
    public function show($id)
    {
        return Keranjang::findOrFail($id);
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, $id)
    {
        $keranjang = Keranjang::findOrFail($id);
        
        $request->validate([
            'meja' => 'sometimes|required|string',
            'nama_pelanggan' => 'sometimes|required|string',
        ]);

        $keranjang->update($request->all());
        return response()->json($keranjang, 200);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy($id)
    {
        $keranjang = Keranjang::findOrFail($id);
        $keranjang->delete();
        return response()->json(null, 204);
    }
}
